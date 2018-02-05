# Prove that loser-elimination methods do not all pass Greg Dennis's
# "Independence of Weaker Alternatives", contrary to intuition.

var numvoters;

var ABCD integer >= 0;
var ABDC integer >= 0;
var ACBD integer >= 0;
var ACDB integer >= 0;
var ADBC integer >= 0;
var ADCB integer >= 0;
var BACD integer >= 0;
var BADC integer >= 0;
var BCAD integer >= 0;
var BCDA integer >= 0;
var BDAC integer >= 0;
var BDCA integer >= 0;
var CABD integer >= 0;
var CADB integer >= 0;
var CBAD integer >= 0;
var CBDA integer >= 0;
var CDAB integer >= 0;
var CDBA integer >= 0;
var DABC integer >= 0;
var DACB integer >= 0;
var DBAC integer >= 0;
var DBCA integer >= 0;
var DCAB integer >= 0;
var DCBA integer >= 0;

var ABCwo integer >= 0;
var ACBwo integer >= 0;
var BACwo integer >= 0;
var BCAwo integer >= 0;
var CABwo integer >= 0;
var CBAwo integer >= 0;
var fpAwo integer >= 0;
var fpBwo integer >= 0;
var fpCwo integer >= 0;
var fpC integer >= 0;
var fpA integer >= 0;
var fpD integer >= 0;
var fpB integer >= 0;
var ACDwob integer >= 0;
var ADCwob integer >= 0;
var CADwob integer >= 0;
var CDAwob integer >= 0;
var DACwob integer >= 0;
var DCAwob integer >= 0;
var fpAwob integer >= 0;
var fpCwob integer >= 0;
var fpDwob integer >= 0;

minimize numv: numvoters;

# Define the number of voters as the sum of all ranks

s.t. numvoters_const:
	ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + BACD + BADC + BCAD + BCDA + BDAC + BDCA + CABD + CADB + CBAD + CBDA + CDAB + CDBA + DABC + DACB + DBAC + DBCA + DCAB + DCBA + 0 = numvoters;

# The setup required to create the disproof for IRV consists of the following:
# Before introducing D:
#	- When dealing only with A, B, and C:    C must lose
#	- When dealing with only A and B:        B must lose (i.e. A>B pairwise)
# This fixes the IRV order as A>B>C.

# After introducing D:
#	- When dealing with all four candidates: B must lose
#	- When dealing with only A, C, D:	 D must lose
#	- When dealing with only A and C:	 A must lose (i.e. C>A pairwise)
# This fixes the IRV order as C>A>D>B.

# -------------------------------------------------------------------------

# Three candidates without D

s.t. ABCwo_c:	ABCwo = ABCD + ABDC + ADBC + DABC;
s.t. ACBwo_c:	ACBwo = ACBD + ACDB + ADCB + DACB;
s.t. BACwo_c:	BACwo = BACD + BADC + BDAC + DBAC;
s.t. BCAwo_c:	BCAwo = BCAD + BCDA + BDCA + DBCA;
s.t. CABwo_c:	CABwo = CABD + CADB + CDAB + DCAB;
s.t. CBAwo_c:	CBAwo = CBAD + CBDA + CDBA + DCBA;

s.t. fpAwo_c:	fpAwo = ABCwo + ACBwo;
s.t. fpBwo_c:	fpBwo = BACwo + BCAwo;
s.t. fpCwo_c:	fpCwo = CABwo + CBAwo;

s.t. order_tcD_A:	fpCwo <= fpAwo - 1;	# C must rank below A
s.t. order_tcD_B:	fpCwo <= fpBwo - 1;	# C must rank below B

# Four candidates

s.t. fpC_c:	fpC = CABD + CADB + CBAD + CBDA + CDAB + CDBA;
s.t. fpA_c:	fpA = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB;
s.t. fpD_c:	fpD = DABC + DACB + DBAC + DBCA + DCAB + DCBA;
s.t. fpB_c:	fpB = BACD + BADC + BCDA + BCAD + BDCA + BDAC;

s.t. order_four_D:	fpB <= fpD - 1;		# B must rank below D
s.t. order_four_A:	fpB <= fpA - 1;		# B must rank below A
s.t. order_four_C:	fpB <= fpC - 1;		# B must rank below C

# Three candidates without B

s.t. ACDwob_c:	ACDwob = ACDB + ACBD + ABCD + BACD;
s.t. ADCwob_c:	ADCwob = ADCB + ADBC + ABDC + BADC;
s.t. CADwob_c:	CADwob = CADB + CABD + CBAD + BCAD;
s.t. CDAwob_c:	CDAwob = CDAB + CDBA + CBDA + BCDA;
s.t. DACwob_c:	DACwob = DACB + DABC + DBAC + BDAC;
s.t. DCAwob_c:	DCAwob = DCAB + DCBA + DBCA + BDCA;

s.t. fpAwob_c:	fpAwob = ACDwob + ADCwob;
s.t. fpCwob_c:	fpCwob = CADwob + CDAwob;
s.t. fpDwob_c:	fpDwob = DACwob + DCAwob;

s.t. order_tcB_A:	fpDwob <= fpAwob - 1;	# D must rank below A
s.t. order_tcB_C:	fpDwob <= fpCwob - 1;	# D must rank below C

# A beats B pairwise
s.t. ab: ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + CABD + CADB + CDAB + DABC + DACB + DCAB - BACD - BADC - BCAD - BCDA - BDAC - BDCA - CBAD - CBDA - CDBA - DBAC - DBCA - DCBA >= 1;

# C beats A pairwise
s.t. ca: BCAD + BCDA + BDCA + CABD + CADB + CBAD + CBDA + CDAB + CDBA + DBCA + DCAB + DCBA - ABCD - ABDC - ACBD - ACDB - ADBC - ADCB - BACD - BADC - BDAC - DABC - DACB - DBAC >= 1;
