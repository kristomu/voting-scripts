# Check whether it's possible to have a three-candidate scenario where B is
# the Condorcet winner, yet all of the below hold (fp* means the number of first
# preferences for *):
#	fpA > fpB
#	fpC > fpA
#	fpC < numvoters/2

# which we can call the "strong Chicken Dilemma conditions against B".

# To model strict inequality (less than, greater than) with LP's >= <=, we
# add nonnegative epsilons to each side and set the LP objective to maximize
# them. If the epsilons are 0 or the program is infeasible, that proves it's
# not possible to have a Condorcet winner with the properties above; otherwise,
# we have a counterexample where Condorcet is incompatible with the strong CD
# conditions.

var ABC >= 0;
var ACB >= 0;
var BAC >= 0;
var BCA >= 0;
var CAB >= 0;
var CBA >= 0;
var eps >= 0;

maximize epsilon: eps;

s.t. cd_criterion_one:
	ABC + ACB >= BAC + BCA + eps;

s.t. cd_criterion_two:
	CAB + CBA >= ABC + ACB + eps;

s.t. cd_criterion_three:
	2 * (CAB + CBA) + eps <= ABC + ACB + BAC + BCA + CAB + CBA;

s.t. b_beats_a:
	BAC + BCA + CBA >= ABC + ACB + CAB + eps;

s.t. b_beats_c:
	BAC + BCA + ABC >= CAB + CBA + ACB + eps;

#s.t. c_indifference:
#	CAB = CBA;

s.t. bac_zero:
	BAC = 0;

s.t. eps_upper_bound:
	eps <= 10;

solve;

printf "Epsilon is %f\n", eps;
