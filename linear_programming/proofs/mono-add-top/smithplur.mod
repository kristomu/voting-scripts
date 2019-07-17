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
var minmaxA >= 0;
var minmaxB >= 0;
var minmaxC >= 0;

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
	BbD <= DbB + x;
s.t. allbeatsD_three:
	CbD >= DbC + 1;

s.t. BbD_weak:
	BbD <= DbB + x + 1;
s.t. CbA_strong:
	CbA >= AbC + x + 1;

s.t. d_first:
	fpA + x + 1 <= fpD;
s.t. a_second_i:
	fpA >= fpB + 1;
s.t. a_second_ii:
	fpA >= fpC + 1;
solve;
