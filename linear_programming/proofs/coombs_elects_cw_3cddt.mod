# Prove that Coombs' method always elects the CW in the three-
# candidate case - by trying to set up a counterxample and having
# the LP solver show that it's infeasible.

var ABC >= 0;
var ACB >= 0;
var BAC >= 0;
var BCA >= 0;
var CAB >= 0;
var CBA >= 0;
var lpA >= 0;
var lpB >= 0;
var lpC >= 0;
var v >= 0;

minimize voters: v;

# Defint the number of voters.

s.t. defV: v = ABC + ACB + BAC + BCA + CAB + CBA;

# Define last preferences.

s.t. lpA_def: lpA = BCA + CBA;
s.t. lpB_def: lpB = CAB + ACB;
s.t. lpC_def: lpC = ABC + ACB;

# A is the CW and hence beats B and C pairwise.

s.t. AbeatsB: ABC + ACB + CAB >= BAC + BCA + CBA + 1;
s.t. AbeatsC: ABC + ACB + BAC >= CAB + CBA + BCA + 1;

# A must be eliminated in the first round, hence have
# more last preferences than B and C.

s.t. AlosestoB: lpA >= lpB + 1;
s.t. AlosestoC: lpA >= lpC + 1;

solve;
