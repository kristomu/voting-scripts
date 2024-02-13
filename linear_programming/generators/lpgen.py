import itertools
from tqdm import tqdm

from subprocess import Popen, PIPE

# I'd like to use this to try to find a disjoint resistant set with
# summable structure (first preferences, Condorcet matrix) equal/collision.

# Sketch: whether A ~> B is given as input. We start with say, the
# first election's set being A and the second's being B (recurse over every
# possible pair of resistant sets), then for any given resistant set,
# find the disqualifications compatible with them - iterate over each.
# Each pick of disqualifications for each pair of sets gives one linear
# program to be checked.

# I don't know how many there would be.

# https://stackoverflow.com/a/18035641
def powerset(iterable):
	"powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
	s = list(iterable)
	return itertools.chain.from_iterable(
		itertools.combinations(s, r) for r in range(len(s)+1))

# Returns a bunch of tuples where the ith element ranges from [0..i].
# This is exactly the number of factoradic digits of length n, and can
# be used to produce every permutation by index.
def indexed_permutations(n):
	return itertools.product(*[range(x+1) for x in range(0, n)])


# Returns every permutation where the values in the list order appear in
# the order given.

# I did not write this function.
def T_generate_permutations_with_order(item_set, order):
	if len(item_set) > 5:
		raise ValueError("Too many items")

	# Generate all permutations of the item set
	all_permutations = list(itertools.permutations(item_set))

	# Get the subset of items in the specified order
	ordered_subset = [perm for perm in all_permutations if \
		tuple(order) == tuple(item for item in perm if item in order)]

	return ordered_subset

# Returns every permutation with certain values in certain places.
# For instance, item_set = range(4) and place_array [-1, 1, -1, -1]
# returns every permutation with the value 1 in second place.

# I did not write this function.
def T_generate_permutations_with_values(item_set, place_array):
	if len(item_set) > 5:
		raise ValueError("Too many items")

	# Get the indices of the specific positions
	specific_indices = [i for i, val in enumerate(place_array) if val != -1]

	# Get the values for the specific positions
	specific_values = [val for val in place_array if val != -1]

	# Generate all permutations of the item set
	all_permutations = list(itertools.permutations(item_set))

	# Filter permutations based on specific values at specific positions
	filtered_permutations = [perm for perm in all_permutations if \
		all(perm[i] == val for i, val in zip(specific_indices, specific_values))]

	return filtered_permutations

# Voting related stuff below.

# Turns something like [0, 1, 2] into "ABC", i.e. to a ballot name.

def cname(idx):
	return chr(ord('A') + idx)

def tuple_to_var_name(tuple):
	return "".join([cname(idx) for idx in tuple])

# The following functions return lists of tuples of the form
#	(definition type, variable name, equality/inequality, right hand side).
# E.g. defining a variable x <= 3 * y would be
#	(DEF_REAL, "x", "<=", "3 * y")
# while a constraint relating a left-hand and right-hand side, e.g.
#	x + y <= 2x - 3y would be
#	(DEF_CONSTRAINT, "x + y", "<=", "2*x - 3*y").
# This is needed because AMPL/GMPL first requires that we define the
# variable itself with var;, and later set up a constraint with s.t.
# We can't do both at once.

# Definition types. Note that definitions of variables that are defined
# in terms of other variables are always defined as REAL, because we
# lose nothing by doing so.
DEF_CONSTRAINT = 0
DEF_INTEGER = 1
DEF_REAL = 2

# Defines every free permutation variable as well as the convenience
# variable "v" that gives the number of voters.

def is_definition(deftype):
	return deftype != DEF_CONSTRAINT

def all_permutation_vars(election_name, numcands, deftype=DEF_REAL):
	all_permutations = list(itertools.permutations(range(numcands)))

	definitions = [(deftype, election_name + "_" + tuple_to_var_name(x), ">=", 0) \
		for x in all_permutations]

	definitions.append((
		 # This is a sum of other variables, thus we lose nothing by making
		 # it real.
		DEF_REAL,
		election_name + "_v",
		"=",
		" + ".join([election_name + "_" + tuple_to_var_name(perm) \
			for perm in all_permutations])))

	return definitions

# Creates constraints setting two elections' variables equal.
# The "bare variables" input should contain a tuple list defining these
# variables, but with no election name. Then we just return these prefixed
# with the election names.

def link_elections(election_names, bare_variables):
	definitions = []
	first_election = election_names[0]

	for other_election in election_names[1:]:
		definitions += [(DEF_CONSTRAINT, first_election + bv[1],
			"=", other_election + bv[1]) for bv in bare_variables]

	return definitions

# Defines pairwise magnitude variables (Condorcet matrix).

def pairbeats(election_name, incumbent, challenger, numcands):
	# Get every tuple contributing to the pairwise defeat strength of the
	# incumbent over the challenger.
	item_set = range(numcands)
	order = [incumbent, challenger]

	perms_in_order = T_generate_permutations_with_order(item_set, order)

	variable_name = "%s_%sb%s" % (election_name,
		cname(incumbent), cname(challenger))
	constraint_type = "="
	rhs = " + ".join([election_name + "_" + tuple_to_var_name(perm) \
			for perm in perms_in_order])

	return (DEF_REAL, variable_name, constraint_type, rhs)

def def_condorcet_matrix(election_name, numcands):
	condmat = []

	for i in range(numcands):
		for j in range(numcands):
			if i == j:
				continue

			condmat.append(pairbeats(election_name, i, j, numcands))

	return condmat

# Returns the variable for candidate "candidate"'s first preferences in the
# subelection defined by the continuing candidates.

def first_pref_subelection(election_name, candidate, subelection, numcands):

	# First generate every variable for the continuing candidates alone.

	place_array = [candidate] + [-1] * (len(subelection)-1)
	cont_cand_values = T_generate_permutations_with_values(subelection,
		place_array)

	# Now for each of these, create the full election variables that have the
	# continuing candidates in the proper order. Avoid duplicated values (not
	# sure if this can happen but...)
	subelection_fps = set()

	# This works by the continuing candidate value being e.g. [0, 2, 5], and
	# then we add every ballot type that has 0, 2, 5 in that order, because
	# they all contribute to [0, 2, 5] in the subelection where only those
	# three candidates are continuing.
	all_cands = list(range(numcands))
	for continuing_order in cont_cand_values:
		perms_with_order = T_generate_permutations_with_order(all_cands,
			continuing_order)
		for p in perms_with_order:
			subelection_fps.add(p)

	subelection_fp_vars = sorted(list(subelection_fps))

	variable_name = "%s_fp%ssub%s" % (election_name, cname(candidate),
		tuple_to_var_name(subelection))
	constraint_type = "="
	rhs = " + " .join([election_name + "_" + tuple_to_var_name(perm) \
			for perm in subelection_fp_vars])

	return (DEF_REAL, variable_name, constraint_type, rhs)

# Creates the constraints that the disqualifying candidate disqualifies
# the disqualified candidate according to the resistant set disqualification
# relation.

def disqualify(election_name, disqualifying, disqualified, numcands):
	# For each subelection of cardinality S, containing both the
	# disqualifying and disqualified candidates, the former must
	# have at least (number of voters) / |S| support. We use + 1
	# to implement the strict inequality.

	other_cddts = set(range(numcands)) - set([disqualifying, disqualified])

	constraints_defs = []

	# Go through every possible inclusion of other candidates, adding
	# both our disqualifying and disqualified candidates to them. This
	# way we're guaranteed to reach every set containing the two key
	# candidates.
	for other_cddt_tuple in powerset(other_cddts):
		this_subelection = sorted(other_cddt_tuple +
			(disqualifying, disqualified))

		# We need the first preferences for the disqualifying candidate.

		fp_disqualifier = first_pref_subelection(election_name,
			disqualifying, this_subelection, numcands)
		constraints_defs.append(fp_disqualifier)

		# And the constraint.

		constraints_defs.append((DEF_CONSTRAINT,
			# Cardinality times number of first preferences
			"%d * %s" % (len(this_subelection), fp_disqualifier[1]),
			">=",
			# Number of voters plus one.
			"%s_v + 1" % (election_name)))

	return constraints_defs

def AMPL_variable_defs(def_constraints):
	definition_str = ""

	variables_seen = set()
	for deftype, var_name, const_type, rhs in sorted(def_constraints):
		# If it's not a definition, skip.
		if not is_definition(deftype): continue
		# If it's a duplicate definition, skip.
		if var_name in variables_seen: continue

		if deftype == DEF_INTEGER:
			qualifier = " integer"
		else:
			qualifier = ""
 
		definition_str += "var %s%s;\n" % (var_name, qualifier);
		variables_seen.add(var_name)

	return definition_str

def AMPL_constraints(def_constraints):
	constraints_str = ""

	variables_seen = set()
	constraint_count = 0

	for deftype, lhs, const_type, rhs in sorted(def_constraints):
		# If it's a definition we've seen before, skip
		if is_definition(deftype):
			if lhs in variables_seen:
				continue
			else:
				variables_seen.add(lhs)

		constraints_str += "s.t. const_%d: %s %s %s;\n" % (
			constraint_count, lhs, const_type, rhs)
		constraint_count += 1

	return constraints_str

# Disqualifying_candidates is a list of numcands length. The ith
# candidate entry x_i is
#	0 < x_i < i: denoting that candidate i is disqualified by x_i
#   x_i = i:	denoting that candidate i is undisqualified. 

def AMPL_disqualification(disqualifying_candidates, numcands):
	election_name = "first"

	# We need to define all the possible ballot permutations.
	def_constraints = all_permutation_vars(
		election_name, numcands)

	# Add disqualification constraints
	for i in range(numcands):
		x_i = disqualifying_candidates[i]
		if x_i > i or x_i < 0:
			raise ValueError("Out of bounds variable x_i = %d for i = %d" %
				(x_i, i))
		if x_i < i:
			disqualifying = x_i
			disqualified = i

			def_constraints += disqualify(election_name,
				disqualifying, disqualified, numcands)

	# Create AMPL.
	program = "# Disqualification test: disqualifier list: %s\n" % (
		disqualifying_candidates)
	program += AMPL_variable_defs(def_constraints)
	# We need to minimize *something*.
	program += "\nminimize numvoters: %s_v;" % election_name
	program += "\n\n"
	program += AMPL_constraints(def_constraints)
	program += "\n\nsolve;\n"

	return program

# Create a program for finding two elections where one has at least
# the disqualifications given by disqualifying_candidates, and the
# other has the relation given by sec_disqualifying.

# sec_disqualifying needs a bit of explanation. We only need to
# define disqualifications for those candidates who are undisqualified
# in the first election. But we need to consider every possible rotation
# (relabeling of candidates) as separate because the candidate order is
# given by the first election.

# So sec_disqualifying is a list of lists. Let k be the number of
# undisqualified candidates. The first sublist, perm, is a choice of k
# candidates out of numcands. The second sublist, sec_disqualifiers,
# is also of length k, and has the same format as disqualifying_candidates,
# except:
#	x_i < i		ith undisqualified candidate is disqualified by perm[x_i]
#	x_i = i		not allowed
# and if perm[x_i] = i or the length of sec_disqualifiers is off, it throws
# an exception.

# This will produce *some* redundant programs, but shouldn't be too many.
# I can ponder how to get rid of the duplicates later.

def get_undisqualified_indices(disqualifying_candidates):
	undisqualified_candidates = []
	for i in range(len(disqualifying_candidates)):
		if disqualifying_candidates[i] == i:
			undisqualified_candidates.append(i)

	return undisqualified_candidates

def dual_AMPL_disqualification(disqualifying_candidates,
	sec_disqualifying, numcands,
	first_pref_linkage=True, pairwise_linkage=True):

	# Transform the sec_disqualifying references and check that
	# they're actually undisqualified in the first election.
	undisqualified_candidates = get_undisqualified_indices(
		disqualifying_candidates)

	perm, sec_disqualifiers = sec_disqualifying

	if len(perm) != len(undisqualified_candidates):
		raise Exception("Perm is the wrong size")
	if len(sec_disqualifiers) != len(undisqualified_candidates):
		raise Exception("sec_disqualifiers is the wrong size")

	# Transform into roughly the same format as
	# disqualifying_candidates, but without the less than
	# constraint, as the permutation of perm ensured that
	# we'll be cycle-free.
	# We start with every candidate being undisqualified.
	sec_dcand = list(range(numcands))

	for i in range(len(undisqualified_candidates)):
		candidate_idx = undisqualified_candidates[i]
		disqualified_by = perm[sec_disqualifiers[i]]

		if candidate_idx == disqualified_by:
			raise ValueError("Candidate can't disqualify himself")

		# Note that we can have disqualified_by > candidate_idx here
		sec_dcand[candidate_idx] = disqualified_by

	# We need to define all the possible ballot permutations.
	def_constraints = all_permutation_vars(
		"first", numcands)
	def_constraints += all_permutation_vars(
		"second", numcands)

	# Add disqualification constraints
	for i in range(numcands):
		x_i = disqualifying_candidates[i]
		if x_i > i or x_i < 0:
			raise ValueError("Out of bounds variable x_i = %d for i = %d" %
				(x_i, i))
		if x_i < i:
			disqualifying = x_i
			disqualified = i

			def_constraints += disqualify("first",
				disqualifying, disqualified, numcands)

		if sec_dcand[i] != i:
			def_constraints += disqualify("second",
				sec_dcand[i], i, numcands)

	# Link the first and second election's first preferences.
	for candidate in range(numcands):
		if not first_pref_linkage: continue

		def_constraints.append(first_pref_subelection(
			"first", candidate, range(numcands), numcands))
		def_constraints.append(first_pref_subelection(
			"second", candidate, range(numcands), numcands))

		def_constraints += link_elections(["first", "second"],
			[first_pref_subelection("", candidate,
			range(numcands), numcands)])

	# Link the first and second election's pairwise preferences.
	for candidate in range(numcands):
		if not pairwise_linkage: continue

		def_constraints += \
			def_condorcet_matrix("first", numcands)
		def_constraints += \
			def_condorcet_matrix("second", numcands)

		def_constraints += link_elections(["first", "second"],
			def_condorcet_matrix("", numcands))

	# Create AMPL.
	program = "# Disqualification test: disqualifier list: %s\n" % (
		disqualifying_candidates,)
	program = "# Disqualification test: second election: perm: %s\n" % (
		perm,)
	program = "# Disqualification test: second election: disqualifiers: %s\n" % (
		sec_disqualifiers,)

	program += AMPL_variable_defs(def_constraints)
	# We need to minimize *something*.
	program += "\nminimize numvoters: first_v + second_v;"
	program += "\n\n"
	program += AMPL_constraints(def_constraints)
	program += "\n\nsolve;\n"

	return program

def do_glpsol(program):
	# Quick and dirty, I know... I should create a proper temporary
	# file to use to avoid race conditions etc. But for now...

	open("temp.mod", "w").write(program)
	process = Popen(["glpsol", "--math", "temp.mod"], stdout=PIPE)
	(output, err) = process.communicate()
	exit_code = process.wait()

	if b"HAS NO PRIMAL" in output:
		return "No primal", output
	else:
		return "Maybe?", output

# Possible detection: (0, 0, 0, 1) [(3,), (0,)]
# That should not happen: this should produce a cycle
# and thus be impossible to satisfy!
# TODO: Determine just what goes wrong.

def do_dual_disqualification(numcands,
	first_pref_linkage=True, pairwise_linkage=True):

	# disqualifying_candidates can be factoradic digit with numcands digits.
	# perm is [0..numcands], k times.
	# sec_disqualifiers is [0...k) * k.

	counter = 0
	last_maybe_output = None

	for disqualifying_candidates in tqdm(
		list(indexed_permutations(numcands))):
		tqdm.write(str(disqualifying_candidates))
		# Determine the number of undisqualified candidates.
		k = len(get_undisqualified_indices(
			disqualifying_candidates))

		for perm in itertools.combinations_with_replacement(
			range(numcands), k):

			for sec_disqualifiers in itertools.\
				combinations_with_replacement(
					range(k), k):

				try:
					program = dual_AMPL_disqualification(
						disqualifying_candidates,
						[perm, sec_disqualifiers],
						numcands,
						first_pref_linkage, pairwise_linkage)
					status, output = do_glpsol(program)
					#print(counter, status)
					if status != "No primal":
						tqdm.write("Possible disproof: %s [%s, %s]" %
							(disqualifying_candidates,
								perm,
								sec_disqualifiers))
						# Try to find the last objective function line
						# XXX: This is ugly!
						objective_value = ""
						for line in output.decode("utf-8").split("\n"):
							if "obj =" in line:
								objective_value = line
						if objective_value != "":
							tqdm.write(objective_value)
						last_maybe_output = output
					counter += 1
				except ValueError:
					pass

	return counter, last_maybe_output

#def dual_AMPL_disqualification(disqualifying_candidates,
#	sec_disqualifying, numcands,
#	first_pref_linkage=True, pairwise_linkage=True):

	

# Example usage
item_set = [0, 1, 2]
order = [0, 1]

permutations_with_order = T_generate_permutations_with_order(item_set, order)
print(permutations_with_order)

item_set = [0, 1, 2, 3]
place_array = [0, -1, -1, 3]

permutations_with_values = T_generate_permutations_with_values(item_set, place_array)
print(permutations_with_values)