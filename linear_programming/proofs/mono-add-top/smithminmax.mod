var AbB >= 0 integer;
var AbC >= 0 integer;
var AbD >= 0 integer;
var BbA >= 0 integer;
var BbC >= 0 integer;
var BbD >= 0 integer;
var CbA >= 0 integer;
var CbB >= 0 integer;
var CbD >= 0 integer;
var DbA >= 0 integer;
var DbB >= 0 integer;
var DbC >= 0 integer;
var v >= 0;
var x >= 1;
var maxAgainstA >= 0;
var maxAgainstB >= 0;
var maxAgainstC >= 0;
var maxAgainstD >= 0;

var ABCD >= 0 integer;
var ABDC >= 0 integer;
var ACBD >= 0 integer;
var ACDB >= 0 integer;
var ADBC >= 0 integer;
var ADCB >= 0 integer;
var BACD >= 0 integer;
var BADC >= 0 integer;
var BCAD >= 0 integer;
var BCDA >= 0 integer;
var BDAC >= 0 integer;
var BDCA >= 0 integer;
var CABD >= 0 integer;
var CADB >= 0 integer;
var CBAD >= 0 integer;
var CBDA >= 0 integer;
var CDAB >= 0 integer;
var CDBA >= 0 integer;
var DABC >= 0 integer;
var DACB >= 0 integer;
var DBAC >= 0 integer;
var DBCA >= 0 integer;
var DCAB >= 0 integer;
var DCBA >= 0 integer;

var fpA >= 0 integer;
var fpB >= 0 integer;
var fpC >= 0 integer;
var fpD >= 0 integer;

var bA1 >= 0 binary;
var bA2 >= 0 binary;
var bA3 >= 0 binary;
var bB1 >= 0 binary;
var bB2 >= 0 binary;
var bB3 >= 0 binary;
var bC1 >= 0 binary;
var bC2 >= 0 binary;
var bC3 >= 0 binary;
var bD1 >= 0 binary;
var bD2 >= 0 binary;
var bD3 >= 0 binary;

param M := 10000;

minimize voters: v;

# Boilerplate making sure the Condorcet matrix is realizable

s.t. AbB_link:
	AbB = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + CABD + CADB + CDAB + DABC + DACB + DCAB;
s.t. AbC_link:
	AbC = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + BACD + BADC + BDAC + DABC + DACB + DBAC;
s.t. AbD_link:
	AbD = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + BACD + BADC + BCAD + CABD + CADB + CBAD;
s.t. BbA_link:
	BbA = BACD + BADC + BCAD + BCDA + BDAC + BDCA + CBAD + CBDA + CDBA + DBAC + DBCA + DCBA;
s.t. BbC_link:
	BbC = ABCD + ABDC + ADBC + BACD + BADC + BCAD + BCDA + BDAC + BDCA + DABC + DBAC + DBCA;
s.t. BbD_link:
	BbD = ABCD + ABDC + ACBD + BACD + BADC + BCAD + BCDA + BDAC + BDCA + CABD + CBAD + CBDA;
s.t. CbA_link:
	CbA = BCAD + BCDA + BDCA + CABD + CADB + CBAD + CBDA + CDAB + CDBA + DBCA + DCAB + DCBA;
s.t. CbB_link:
	CbB = ACBD + ACDB + ADCB + CABD + CADB + CBAD + CBDA + CDAB + CDBA + DACB + DCAB + DCBA;
s.t. CbD_link:
	CbD = ABCD + ACBD + ACDB + BACD + BCAD + BCDA + CABD + CADB + CBAD + CBDA + CDAB + CDBA;
s.t. DbA_link:
	DbA = BCDA + BDAC + BDCA + CBDA + CDAB + CDBA + DABC + DACB + DBAC + DBCA + DCAB + DCBA;
s.t. DbB_link:
	DbB = ACDB + ADBC + ADCB + CADB + CDAB + CDBA + DABC + DACB + DBAC + DBCA + DCAB + DCBA;
s.t. DbC_link:
	DbC = ABDC + ADBC + ADCB + BADC + BDAC + BDCA + DABC + DACB + DBAC + DBCA + DCAB + DCBA;

# Similar boilerplate defining first preferences for later Plurality stuff

s.t. A_fpp:
	fpA = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB;
s.t. B_fpp:
	fpB = BACD + BADC + BCAD + BCDA + BDAC + BDCA;
s.t. C_fpp:
	fpC = CABD + CADB + CBAD + CBDA + CDAB + CDBA;
s.t. D_fpp:
	fpD = DABC + DACB + DBAC + DBCA + DCAB + DCBA;

s.t. votesum:
	fpA + fpB + fpC + fpD = v;

s.t. cycleone:
	AbB >= BbA + 1;
s.t. cycletwo:
	BbC >= CbB + 1;
s.t. cyclethree:
	CbA >= AbC + 1;

s.t. allbeatsD_one:
	AbD >= DbA + 1;
s.t. allbeatsD_two:
	BbD = DbB + x;
s.t. allbeatsD_three:
	CbD >= DbC + 1;

s.t. BbD_weak:
	BbD <= DbB + x + 1;
s.t. CbA_strong:
	CbA >= AbC + x + 1;

# Force maxAgainstA to be A's minmax score.
# The idea is that maxAgainstA must be greater than every pairwise defeat
# strength against A, and then must be smaller than each - but two of the
# "smaller than" bounds can be disengaged by setting the corresponding
# boolean to 1. The solver is permitted to set exactly two of them to 1,
# so that produces equality.

s.t. mA_B:
	maxAgainstA >= BbA;
s.t. mA_C:
	maxAgainstA >= CbA;
s.t. mA_D:
	maxAgainstA >= DbA;
s.t. mA_tight_B:
	maxAgainstA <= BbA + bA1 * M;
s.t. mA_tight_C:
	maxAgainstA <= CbA + bA2 * M;
s.t. mA_tight_D:
	maxAgainstA <= DbA + bA3 * M;
s.t. bounds_mA:
	bA1 + bA2 + bA3 = 2;

s.t. mB_A:
	maxAgainstB >= AbB;
s.t. mB_C:
	maxAgainstB >= CbB;
s.t. mB_D:
	maxAgainstB >= DbB;
s.t. mB_tight_A:
	maxAgainstB <= AbB + bB1 * M; 
s.t. mB_tight_C:
	maxAgainstB <= CbB + bB2 * M;
s.t. mB_tight_D:
	maxAgainstB <= DbB + bB3 * M;
s.t. bounds_mB:
	bB1 + bB2 + bB3 = 2;

s.t. mC_A:
	maxAgainstC >= AbC;
s.t. mC_B:
	maxAgainstC >= BbC;
s.t. mC_D:
	maxAgainstC >= DbC;
s.t. mC_tight_A:
	maxAgainstC <= AbC + bC1 * M;
s.t. mC_tight_B:
	maxAgainstC <= BbC + bC2 * M;
s.t. mC_tight_D:
	maxAgainstC <= DbC + bC3 * M;
s.t. bounds_mC:
	bC1 + bC2 + bC3 = 2;

s.t. mD_A:
	maxAgainstD >= AbD;
s.t. mD_B:
	maxAgainstD >= BbD;
s.t. mD_C:
	maxAgainstD >= CbD;
s.t. mD_tight_A:
	maxAgainstD <= bD1 * M + AbD;
s.t. mD_tight_B:
	maxAgainstD <= bD2 * M + BbD;
s.t. mD_tight_C:
	maxAgainstD <= bD3 * M + CbD;
s.t. bounds_mD:
	bD1 + bD2 + bD3 = 2;

s.t. Dfirst:
	maxAgainstD + 1 + x <= maxAgainstA;
s.t. Dfirst_ii:
	maxAgainstD + 1 + x <= maxAgainstB;
s.t. Dfirst_iii:
	maxAgainstD + 1 + x <= maxAgainstC;

s.t. Asecond:
	maxAgainstA + 1 <= maxAgainstB;
s.t. Asecond_ii:
	maxAgainstA + 1 <= maxAgainstC;

solve;
