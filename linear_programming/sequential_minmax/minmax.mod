# Singlewinner minmax:
# Elect the candidate with minimal maximal opposition.
# This script is properly speaking Minimax(margins).

# The way it works is to do
# minimize maxA + maxB + maxC + ...

# subject to:
#	for all X, for all Y != X
#		maxX >= chosen[X] * Y>X - chosen[X] * X>Y	<-- maximal opp
#	(sum over all X: chose[X]) = 1	<-- choose one candidate

# =============================================================================
# =============================================================================

param numcands, integer > 0;

set CANDIDATES := 1..numcands;

param condorcet_matrix{i in CANDIDATES, k in CANDIDATES};
set candidate_names;

var max_opposition{i in CANDIDATES};

# Note that 0 <= chosen[i] <= 1 will work just as well because the LP
# will force chosen to one of the extrema for each candidate unless there's a 
# tie. However, I'm setting it to binary for the sake of clarity. The IP phase 
# should finish immediately.
var chosen{i in CANDIDATES} binary;

minimize obj: sum{i in CANDIDATES} max_opposition[i];

# Each max opposition is greater than or equal to a particular opposition
# against that candidate
s.t. max_opposition_bound{i in CANDIDATES, j in CANDIDATES}:
	if i != j then
		max_opposition[i] >= condorcet_matrix[j, i] * chosen[i] -
				     condorcet_matrix[i, j] * chosen[i];

# Exactly one winner (will tiebreak according to the LP solver).
s.t. one_winner: sum {i in CANDIDATES} chosen[i] = 1;

solve;

for {i in CANDIDATES}
{
	printf "Candidate %d: max opposition: %d, chosen: %d", 
		i, max_opposition[i], chosen[i];

	# https://en.wikibooks.org/wiki/GLPK/GMPL_Workarounds

	for {{0}: chosen[i] > 0} {	
		printf "\tWINNER";
	}
	printf "\n";
}

data;

param numcands := 4;

# Clone example from https://en.wikipedia.org/w/index.php?title=Independence_of_clones_criterion&oldid=696215064#Minimax
# Minmax chooses A and pretty much every other Condorcet method chooses one of 
# the Bs.

# Candidate names are A B1 B2 B3.

param condorcet_matrix:   1 2 3 4 :=
			1 0 4 4 4
			2 5 0 6 3
			3 5 3 0 6
			4 5 6 3 0;
