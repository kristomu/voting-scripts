# Find two ballot sets that produce the same pairwise values, but where
# {A, B} is the only clone set according to the first ballot set, and
# {A, B} is not a clone set according to the second ballot set.

# If such a pair of ballot sets exists, then it's impossible to determine
# clone sets from pairwise values alone (and this turns out to be the case).

var ABCa >= 0.6;	# No ties (0.5)
var ACBa >= 0;		# All other preference fractions must be nonnegative
var BACa >= 0;
var BCAa >= 0;
var CABa >= 0;
var CBAa >= 0;
var ABCb >= 0; 
var ACBb >= 0; 
var BACb >= 0;
var BCAb >= 0;
var CABb >= 0; 
var CBAb >= 0;

maximize opt: ACBb + BCAb;	# Doesn't matter what you're optimizing

# A>B must be equal for the two ballot sets
s.t. equalAB:
	ABCa + ACBa + CABa - ABCb - ACBb - CABb = 0;

# A>C must be equal for the two ballot sets
s.t. equalAC:
	ACBa + ABCa + BACa - ACBb - ABCb - BACb = 0;

# B>C must be equal for the two ballot sets
s.t. equalBC:
	 BACa + BCAa + ABCa - BACb - BCAb - ABCb = 0;

# {A, B} must be a clone in the first ballot set: implies no A>C>B preferences
s.t. cloneone:
	ACBa = 0;

# {A, B} must be a clone in the first ballot set: implies no B>A>C preferences
s.t. clonetwo:
	BACa = 0;

# {A, B} mustn't be a clone in the second ballot set: must have some ACB or BCA
s.t. nonclonedual:
	ACBb + BCAb >= 0.1;

# {A, C} mustn't be a clone in the first ballot set: must have some ABC or CBA
s.t. nonaccloningina:
	ABCa + CBAa >= 0.1;

# {B, C} mustn't be a clone in the first ballot set: must have some BAC or CAB
s.t. nobccloningina:
	BACa + CABa >= 0.1;

# The sum of voting fractions for each preference sums up to 1 (100%)
s.t. simplexone:
	ABCa + ACBa + BACa + BCAa + CABa + CBAa = 1;

s.t. simplextwo:
	ABCb + ACBb + BACb + BCAb + CABb + CBAb = 1;

solve;

# Show the results.

printf "%f %f %f %f %f %f\n", ABCa, ACBa, BACa, BCAa, CABa, CBAa;
printf "%f %f %f %f %f %f\n", ABCb, ACBb, BACb, BCAb, CABb, CBAb;
