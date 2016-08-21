# D'Hondt / Chamberlin-Courant DSV type party list.

# NOTE: This method might have a problem. See below regarding the quota.

# All divisor methods are "floating quota" methods.
# (See https://en.wikipedia.org/wiki/Highest_averages_method#Quota_system)
# I.e. they can be recast as
#	find the quota that gives the number of seats we want, given that the
#	number of seats a party gets is equal to the quota times how many voters
#	are assigned to it, subjected to a rounding function.

# The Chamberlin-Courant part of this method is:
#	- Each voter is assigned to one or more parties.
#	- If voter X is assigned to party p with fraction f, then X contributes
#		(X's rating of p) * f to the objective score.
#	- Assign voters to parties so as to maximize the objective score.
#	- No voter can be more than 100% assigned to parties or less than 0%.

# The D'Hondt DSV part of the method is:
#	- Each party must have exactly the floating quota times some integer
#		number of voters assigned to it. (This means some will be left 
#		over).
#	- Each party gets a number of seats equal to the multiples of quota it
#		has. (I.e any fractional quotas are rounded down, which is what
#		makes this method D'Hondt.)

# The DSV part lies in that each party must have exactly [the quota times an 
# integer] number of voters assigned. Suppose party p happened to have 3.2 
# quotas' worth. Then the 0.2 quotas' worth of voters could be reassigned to
# some other party without harming party p's number of seats (if the quota is
# held constant). Insisting that the number of voters assigned to a party being
# exactly the number needed for an integer multiple of the quota then ensures
# that any surplus will be assigned to some other party if that would help the
# other party. Hence the method shifts the votes around in such a way as to
# minimize wasted votes - but without any elimination.

# The method is based on ratings and so reduces to Range when there's only one
# seat. (I think?)

# TODO: Implement tiebreak cases. See "Mathematics and Democracy: Designing 
# Better Voting and Fair-Division Procedures" p. 127

param dhondt_quota, integer > 0;
param numballots, integer > 0;
param numparties, integer > 0;

set PARTIES := 1..numparties;
set BALLOTS := 1..numballots;

param rating{b in BALLOTS, p in PARTIES};
param ballot_weights{b in BALLOTS};

param num_fielded_candidates{p in PARTIES};

var assigned{b in BALLOTS, p in PARTIES} >= 0;
var quotas{p in PARTIES} integer >= 0;

maximize ratings_sum: sum{b in BALLOTS, p in PARTIES} 
			assigned[b, p] * rating[b,p];

s.t. integer_number_of_quotas{p in PARTIES}:
	(sum{b in BALLOTS} assigned[b, p]) = quotas[p] * dhondt_quota;

s.t. candidate_limit{p in PARTIES}:
	quotas[p] <= num_fielded_candidates[p];

s.t. cant_assign_too_much{b in BALLOTS}:
	(sum{p in PARTIES} assigned[b, p]) <= ballot_weights[b];

solve;

printf "Number of seats: %d\n\n", sum{p in PARTIES} quotas[p];

for {p in PARTIES}
{
	printf "Party %d: quotas: %.2f\n", p, quotas[p];
	
	printf "\tAssignments: ";

	for {b in BALLOTS}:
		printf "%.2f ", assigned[b, p];
	printf "\n\t\tSum apport: %.2f\n", sum{b in BALLOTS} assigned[b, p];
}

data;

# https://en.wikipedia.org/wiki/Highest_averages_method#Comparison_between_the_D.27Hondt_and_Sainte-Lagu.C3.AB_methods

param numparties := 6;
param numballots := 6;

#param dhondt_quota := 7900;	# without integer forcing
# !!! Does not seem to be monotone wrt quota! Lower quota makes the result
# more majoritarian, but we want higher quota to be more majoritarian!
# Maybe we need what Brams calls q=1 both for this and to satisfy IIB.
param dhondt_quota := 9091;
# Uncomment this to see that effect in action.
#param dhondt_quota := 10000;

param ballot_weights := 1 47000 2 16000 3 15900 4 12000 5 6000 6 3100;
param num_fielded_candidates := 1 100 2 100 3 100 4 100 5 100 6 100;

param rating :	1 2 3 4 5 6 :=
	      1 1 0 0 0 0 0
	      2 0 1 0 0 0 0
	      3 0 0 1 0 0 0
	      4 0 0 0 1 0 0
	      5 0 0 0 0 1 0
	      6 0 0 0 0 0 1 ;
