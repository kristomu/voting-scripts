# The three-winner method
# A>B>C>A A's score is C's first pref - A's first prefs
# otherwise CW wins

# passes the Chicken Dilemma criterion.

# The idea is to set up equations where we're in a CD situation but the
# CD's demand that B mustn't win is broken. If that's impossible, then
# the method passes the CD.

# Since the linear programming formulation doesn't support strict inequalities,
# we add an epsilon and ask the LP solver to maximize it. If that epsilon is
# zero, then it's impossible to satisfy all criteria and the method passes the
# CD.

var fpA >= 0;
var fpB >= 0;
var fpC >= 0;
var eps >= 0;

maximize epsilon: eps;

# TODO sometime: we assume the cycle is ABCA. Show that if there is a cycle,
# it must be ABCA; or make a duplicate of this for ACBA.
# (ABCA is (A>B > B>A), (B>C > C>B), (C>A > A>C))

# Set up the CD situation from first preference votes alone
# (This is more strict than the actual CD situation)

s.t. cda:
	fpB + eps <= fpA;	# More A-voters than B-voters	(premise 3)
s.t. cdb:
	fpA + eps <= fpC;	# More C-voters than A-voters	(premise 3)
s.t. cdc:
	fpC + eps <= fpA + fpB;	# C-voters do not have a majority (premise 2)

# We can't detect premises 4 and 5 from first preferences alone, but any CD
# situation must obey the other premises. So if we get infeasibility here, we 
# must have infeasibility over the CD situation space too.

# Now B mustn't win. Demand that it must - we'll get a contradiction.

s.t. b_better_than_a:
	fpA - fpC + eps <= fpB - fpA;	# B is strictly better than A

s.t. b_better_than_c:
	fpC - fpB + eps <= fpB - fpA;	# B is strictly better than C

# If it's ACBA then
# A's score is fpA - fpB
# C's score is fpC - fpA
# B's score is fpB - fpC

#s.t. b_better_than_a:
#	fpA - fpB + eps <= fpB - fpC;

#s.t. b_better_than_c:
#	fpC - fpA + eps <= fpB - fpC;

# and the same happens.

solve;

printf "Epsilon is %f\n", eps;