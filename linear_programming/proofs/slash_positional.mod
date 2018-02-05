# Want to find a mono-raise failure for Smith//Positional where Positional
# is a weighted positional system, e.g. Plurality or Antiplurality.

# Four candidate Smith set ABCA + D>C very weakly, so that C wins when
# every candidate is in play, but doesn't when D is eliminated, and that
# D can be kicked off the Smith set by raising C on a DC ballot.

# For some reason, I can't find a failure with Borda.

# The last weight is assumed to be zero.

# Define the weight parameters. The actual weights are at the bottom
# of the file.
param FourWeights {i in 1..3};
param ThreeWeights {i in 1..2};

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

var ABC >= 0 integer;
var ACB >= 0 integer;
var BAC >= 0 integer;
var BCA >= 0 integer;
var CAB >= 0 integer;
var CBA >= 0 integer;

var AScoreBefore >= 0;
var BScoreBefore >= 0;
var CScoreBefore >= 0;
var DScoreBefore >= 0;
var AScoreAfter >= 0;
var BScoreAfter >= 0;
var CScoreAfter >= 0;

var v >= 0;

minimize numvoters: v;

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

s.t. numvoters_constraint:
	v = ABCD + ABDC + ACBD + ACDB + ADBC + ADCB + BACD + BADC + BCAD + BCDA +
		BDAC + BDCA + CABD + CADB + CBAD + CBDA + CDAB + CDBA + DABC + DACB +
		DBAC + DBCA + DCAB + DCBA;

# Sum of ballots with DC must be greater than zero
s.t. need_something_to_raise:
	ABDC + ADCB + BADC + BDCA + DCAB + DCBA >= 1;

s.t. counts_after_elimination_abc:
	ABC = ABCD + ABDC + ADBC + DABC;

s.t. counts_after_elimination_acb:
	ACB = ACBD + ACDB +  ADCB + DACB;

s.t. counts_after_elimination_bac:
	BAC = BACD + BADC + BDAC + DBAC;

s.t. counts_after_elimination_bca:
	BCA = BCAD + BCDA + BDCA + DBCA;

s.t. counts_after_elimination_cab:
	CAB = CABD + CADB + CDAB + DCAB;

s.t. counts_after_elimination_cba:
	CBA = CBAD + CBDA + CDBA + DCBA;

s.t. bordascores_a_before:
	AScoreBefore =	FourWeights[1] * (ABCD+ABDC+ACBD+ACDB+ADBC+ADCB) +
					FourWeights[2] * (BACD+BADC+CABD+CADB+DABC+DACB) +
					FourWeights[3] * (BCAD+BDAC+CBAD+CDAB+DBAC+DCAB);

s.t. bordascores_b_before:
	BScoreBefore =	FourWeights[1] * (BACD+BADC+BCAD+BCDA+BDAC+BDCA) +
					FourWeights[2] * (ABCD+ABDC+CBAD+CBDA+DBAC+DBCA) +
					FourWeights[3] * (ACBD+ADBC+CABD+CDBA+DABC+DCBA);

s.t. bordascores_c_before:
	CScoreBefore =	FourWeights[1] * (CABD+CADB+CBAD+CBDA+CDAB+CDBA) +
					FourWeights[2] * (ACBD+ACDB+BCAD+BCDA+DCAB+DCBA) +
					FourWeights[3] * (ABCD+ADCB+BACD+BDCA+DACB+DBCA);

s.t. bordascores_d_before:
	DScoreBefore =	FourWeights[1] * (DABC+DACB+DBAC+DBCA+DCAB+DCBA) +
					FourWeights[2] * (ADBC+ADCB+BDAC+BDCA+CDAB+CDBA) +
					FourWeights[3] * (ABDC+ACDB+BADC+BCDA+CADB+CBDA);

# This is after raising C. Since we raise C on a DC ballot (so that it becomes
# a CD ballot, this doesn't affect the counts with D eliminated. We can 
# thus use them without having to add and subtract any votes.

s.t. bordascores_a_after:
	AScoreAfter = 	ThreeWeights[1] * (ABC + ACB) + 
					ThreeWeights[2] * (BAC + CAB);

s.t. bordascores_b_after:
	BScoreAfter =	ThreeWeights[1] * (BAC + BCA) + 
					ThreeWeights[2] * (ABC + CBA);

s.t. bordascores_c_after:
	CScoreAfter =	ThreeWeights[1] * (CAB + CBA) + 
					ThreeWeights[2] * (ACB + BCA);

s.t. cycleone:
	AbB >= BbA + 1;
s.t. cycletwo:
	BbC >= CbB + 1;
s.t. cyclethree:
	CbA >= AbC + 1;

s.t. allbeatsD_but_C_one:
	AbD >= DbA + 1;
s.t. allbeatsD_but_C_two:
	BbD >= DbB + 1;
s.t. allbeatsD_but_C_three:
	# ????
	CbD <= DbC;

s.t. CWinsUneliminated_i:
	CScoreBefore >= AScoreBefore + 1;
s.t. CWinsUneliminated_ii:
	CScoreBefore >= BScoreBefore + 1;
s.t. CWinsUneliminated_iii:
	CScoreBefore >= DScoreBefore + 1;

s.t. ABeatsCAfter:
	AScoreAfter >= CScoreAfter + 1;

solve;

# ---------------------------- weights below here --------------------

data;

# Antiplurality

param FourWeights :=	1 1 
						2 1 
						3 1;

param ThreeWeights :=	1 1 
						2 1;

# Borda
# param FourWeights := 1 3 2 2 3 1;
# param ThreeWeights := 1 2 2 1;

# Plurality
#param FourWeights := 1 1 2 0 3 0;
#param ThreeWeights := 1 1 2 0;
