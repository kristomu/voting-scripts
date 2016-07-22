# Demonstration of the inner round of a minmax-based multiwinner system.
# This is the "maximize weakest victory" formulation, consistent with LeGrand's
# voting simulator rbvote.

# The outer round (not implemented here) goes like this:
# - For each uneliminated candidate:
#	- run the linear program (this one) to see the best minmax score it's
#		possible to give that candidate by using only a quota's worth
#		of voters.
# - Elect the candidate with the best minmax score(here, minimal max opposition)
# - Remove the voters who elected that candidate (i.e. the quota's worth of 
#   voters that the linear program found)
# - If this is a candidate election or it's a party list election where the 
#   party has got as many seats as it fielded candidates: eliminate the winner 
#   from every remaining ballot.
# - Loop to the top until every seat has been filled.

# The inner round is this program. There may be a better way of doing it: this
# is just a proof of concept that this kind of sequential clustering is possible
# in polytime.

# This script is properly speaking Minimax(margins).

# We want to know the maximum opposition score against a given candidate given
# the constraint that we must pick exactly k voters, where k is the Hare quota.
# Say the candidate is A. Then the LP works like this:

# maximize min_support

# subject to:
#	for every candidate Y != A,
#		min_support <= sum over ballots b
#				(ballot_chosen[b] * {voter voted A>Y}
#				- ballot_chosen[b] * {voter voted Y>A})

# for all ballots b:
# 0 <= ballot_chosen[b] <= ballot_weight[b]

# (sum over ballots b: ballot_chosen[b]) = quota

# ----

# A Droop quota variant (not implemented) would work like this: each cluster
# (virtual constituency) must use at least a Droop quota and no more than a
# Hare quota, instead of exactly a Hare quota. Some voters would likely be left
# over, but that's how the Droop system works.

# (Maybe we can have a Webster variant by saying "at least X" and then finding
#  the highest value of X where there are enough winners for every seat??)

# Perhaps do at some future point: see if it's susceptible to
# https://en.wikipedia.org/wiki/Issues_affecting_the_single_transferable_vote#Vote_management_systems

# =============================================================================
# =============================================================================

param numcands, integer > 0;
param numballots, integer > 0;
param numvoters, integer > 0;
param numseats, integer > 0;
param cand_to_eval;	# candidate to evaluate

set CANDIDATES := 1..numcands;
set BALLOTS := 1..numballots;

param ballot_condorcet_matrix{b in BALLOTS, i in CANDIDATES, k in CANDIDATES};
param ballot_num_voters{i in BALLOTS};

var min_support;

var ballot_chosen{b in BALLOTS};

maximize obj: min_support;

# Each max opposition is greater than or equal to a particular opposition
# against that candidate
s.t. max_opposition_bound{i in CANDIDATES}:
	if i != cand_to_eval then
		min_support <= sum {b in BALLOTS} (
			ballot_condorcet_matrix[b, cand_to_eval, i] * 
				ballot_chosen[b] - 
			ballot_condorcet_matrix[b, i, cand_to_eval] * 
				ballot_chosen[b]);

# Per-ballot bounds
s.t. per_ballot_lower_bound{b in BALLOTS}:
	ballot_chosen[b] >= 0;

s.t. per_ballot_upper_bound{b in BALLOTS}:
	ballot_chosen[b] <= ballot_num_voters[b];

# Fill the quota (Hare here).
s.t. full_quota:
	sum{b in BALLOTS} ballot_chosen[b] = numvoters/numseats;

solve;

printf "Minmax score for candidate %d is %d\n", cand_to_eval, min_support;
printf "The quota is %f\n", numvoters/numseats;
printf "The ballots involved:\n";

for {b in BALLOTS}
{
	printf "Ballot %d: %f\n", b, ballot_chosen[b];
}

data;

param numseats := 2;

# Candidate 3 has the least opposition in this example. The ballot weights then
# give what you need to subtract before running the last election, and it's
# pretty clear candidate 1 will win that election, so the sequential approach
# elects 1 and 3, i.e. Clinton and Obama.
param cand_to_eval := 3;

param numcands := 3;
param numballots := 3;
param numvoters := 170;

param ballot_condorcet_matrix := #C M O
        [1,*,*]:  1 2 3 :=      # 68: Clinton > McCain > Obama
                1 0 1 1
                2 0 0 1
                3 0 0 0
        [2,*,*]:  1 2 3 :=      # 33: McCain > Obama > Clinton
                1 0 0 0
                2 1 0 1
                3 1 0 0
        [3,*,*]:  1 2 3 :=      # 69: Obama > Clinton > McCain
                1 0 1 0
                2 0 0 0
                3 1 1 0;

param ballot_num_voters := 1 68 2 33 3 69;
