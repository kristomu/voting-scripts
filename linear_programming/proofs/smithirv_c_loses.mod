# Try to find a DH3 situation where C is the CW, but C is also the IRV loser.
# Such a situation makes two-faction DH3-style defection work in Smith,IRV or
# Smith//IRV, and serves as a proof that the method is not strongly immune to
# such scenarios (analogous to the Strong FBC vs Weak FBC distinction).

# Whether it's weakly immune is a completely different question.

#x1: C>A>B               x3: ABC
#x2: C>B>A               x4: ACB
#x3: A>B>C               x5: BAC
#x4: A>C>B               x6: BCA
#x5: B>A>C               x1: CAB
#x6: B>C>A               x2: CBA

# Let q be the minimum voting strength. Maximize q, i.e. all voting weights 
# should be as close to one another as possible (thus as DH3-like as possible)

# Let the vote weights be integer just to make the numbers easy to handle.

var ABC >= 0 integer;
var ACB >= 0 integer;
var BAC >= 0 integer;
var BCA >= 0 integer;
var CAB >= 0 integer;
var CBA >= 0 integer;

var min_voting_str;

maximize minstr: min_voting_str;


#C is not the IRV winner
#We may need an epsilon. (set to 0.001 here)

s.t. fpC_less_fpA:	# fpA > fpC
	ABC + ACB >= CAB + CBA + 0.001;

s.t. fpC_less_fpB:	# fpB > fpC
	BAC + BCA >= CAB + CBA + 0.001;

# C is the CW:
s.t. C_beats_A:
	CAB + CBA + BCA >= ABC + ACB + BAC + 0.001;

s.t. C_beats_B:
	CAB + CBA + ACB >= BAC + BCA + ABC + 0.001;

# Bound the solution space.
s.t. bound:
	ABC + ACB + BAC + BCA + CAB + CBA <= 200;

# Define min_voting_str.
s.t. mvs_ABC:
	min_voting_str <= ABC;

s.t. mvs_ACB:
	min_voting_str <= ACB;

s.t. mvs_BAC:
	min_voting_str <= BAC;

s.t. mvs_BCA:
	min_voting_str <= BCA;

s.t. mvs_CAB:
	min_voting_str <= CAB;

s.t. mvs_CBA:
	min_voting_str <= CBA;

solve;

printf "Ballot counts:\n ABC: %d\n ACB: %d\n BAC: %d\n BCA: %d\n CAB: %d\n CBA: %d\n", ABC, ACB, BAC, BCA, CAB, CBA;
