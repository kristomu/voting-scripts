# Sainte-Laguë / Chamberlin-Courant DSV type party list.

# See D'Hondt for explanations about the general method. The differences lie
# in the DSV aspect and the quota aspect.

# In D'Hondt, a party gets one seat when it has at least one floating quota's
# worth; it gets two seats when it has at least two, and so on. So the
# transition points are 1 quota, 2 quotas, 3 quotas and so on. This because
# D'Hondt rounds down.

# In contrast, Sainte-Laguë/Webster rounds off. So the first seat is achieved
# at 0.5 quotas, the second at 1.5 quotas, the third at 2.5 quotas and so on;
# or equivalently at 1 half quota, 3 half quotas, 5 half quotas, etc 
# (hence the 2k+1 divisors in Sainte-Laguë).

# This is a problem for the DSV formulation because the distance from 0 to 1
# seat is one half quota, whereas the distance from 1 to 2, 2 to 3, etc is
# one full quota. Hence the first seat has to be processed separately by a
# trick I got from "Applied Mathematical Programming" (Bradley, et al:
# http://web.mit.edu/15.053/www/AMP-Chapter-09.pdf) on specifying piecewise
# linear curves by integer programming.

param sl_quota, integer > 0;
param numballots, integer > 0;
param numparties, integer > 0;

set PARTIES := 1..numparties;
set BALLOTS := 1..numballots;

param rating{b in BALLOTS, p in PARTIES};
param ballot_weights{b in BALLOTS};

# Number of seats must be below this
param VERYLARGE := sum{i in BALLOTS} ballot_weights[i];

param num_fielded_candidates{p in PARTIES};

var assigned{b in BALLOTS, p in PARTIES} >= 0;
var first_seat{p in PARTIES} binary;
var subsequent_seats{p in PARTIES} integer >= 0;

maximize ratings_sum: sum{b in BALLOTS, p in PARTIES} 
			assigned[b, p] * rating[b,p];

s.t. subsequent_seats_only_if_first_seat_enabled{p in PARTIES}:
	subsequent_seats[p] <= VERYLARGE * first_seat[p];

s.t. integer_number_of_seats{p in PARTIES}:
	(sum{b in BALLOTS} assigned[b, p]) = (2 * subsequent_seats[p] + first_seat[p]) * sl_quota/2;

s.t. candidate_limit{p in PARTIES}:
	first_seat[p] + subsequent_seats[p] <= num_fielded_candidates[p];

s.t. cant_assign_too_much{b in BALLOTS}:
	(sum{p in PARTIES} assigned[b, p]) <= ballot_weights[b];

solve;

printf "Number of seats: %d\n\n", sum{p in PARTIES} (first_seat[p] + subsequent_seats[p]);

for {p in PARTIES}
{
	printf "Party %d: quotas: %.2f\n", p, (first_seat[p] + subsequent_seats[p]);
	
	printf "\tAssignments: ";

	for {b in BALLOTS}:
		printf "%.2f ", assigned[b, p];
	printf "\n\t\tSum apport: %.2f\n", sum{b in BALLOTS} assigned[b, p];
}

data;

# https://en.wikipedia.org/wiki/Highest_averages_method#Comparison_between_the_D.27Hondt_and_Sainte-Lagu.C3.AB_methods

param numparties := 6;
param numballots := 6;

# !!! Does not seem to be monotone wrt quota! Lower quota makes the result
# more majoritarian, but we want higher quota to be more majoritarian!
# Maybe we need what Brams calls q=1 both for this and to satisfy IIB.
param sl_quota := 12501;
# Uncomment this to see that effect in action.
#param sl_quota := 14200;

param ballot_weights := 1 47000 2 16000 3 15900 4 12000 5 6000 6 3100;
param num_fielded_candidates := 1 100 2 100 3 100 4 100 5 100 6 100;

param rating :	1 2 3 4 5 6 :=
	      1 1 0 0 0 0 0
	      2 0 1 0 0 0 0
	      3 0 0 1 0 0 0
	      4 0 0 0 1 0 0
	      5 0 0 0 0 1 0
	      6 0 0 0 0 0 1 ;
