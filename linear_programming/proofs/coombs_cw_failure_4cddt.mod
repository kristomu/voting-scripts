# Find an example that Coombs can fail to elect the Condorcet winner
# in the four candidate case. Since it passes Condorcet in the three
# candidate case, the Condorcet winner must have the most last pref
# votes so that he is eliminated in the first round.

var ABCD >= 0 integer;
var ACBD >= 0 integer;
var BACD >= 0 integer;
var BCAD >= 0 integer;
var CABD >= 0 integer;
var CBAD >= 0 integer;
var ABDC >= 0 integer;
var ACDB >= 0 integer;
var BADC >= 0 integer;
var BCDA >= 0 integer;
var CADB >= 0 integer;
var CBDA >= 0 integer;
var ADBC >= 0 integer;
var ADCB >= 0 integer;
var BDAC >= 0 integer;
var BDCA >= 0 integer;
var CDAB >= 0 integer;
var CDBA >= 0 integer;
var DABC >= 0 integer;
var DACB >= 0 integer;
var DBAC >= 0 integer;
var DBCA >= 0 integer;
var DCAB >= 0 integer;
var DCBA >= 0 integer;

var lpA >= 0;
var lpB >= 0;
var lpC >= 0;
var lpD >= 0;
var fpA >= 0;
var v >= 0;

minimize voters: v;

# Define the number of voters.

s.t. defV: v = ABCD + ACBD + BACD + BCAD + CABD + CBAD + ABDC + ACDB + BADC + BCDA + CADB + CBDA + ADBC + ADCB + BDAC + BDCA + CDAB + CDBA + DABC + DACB + DBAC + DBCA + DCAB + DCBA;

# Define last preferences.

s.t. lpA_def: lpA = BCDA + CBDA + BDCA + CDBA + DBCA + DCBA;
s.t. lpB_def: lpB = ACDB + CADB + ADCB + CDAB + DACB + DCAB;
s.t. lpC_def: lpC = ABDC + BADC + ADBC + BDAC + DABC + DBAC;
s.t. lpD_def: lpD = ABCD + ACBD + BACD + BCAD + CABD + CBAD;

# Define A's first preferences to keep A from being immediately
# elected by the majority criterion of Coombs.

s.t. fpA_def: fpA = ABCD + ACBD + ABDC + ACDB + ADBC + ADCB;

# A is the CW and hence beats B, C, and D pairwise.

s.t. AbeatsB: ABCD + ACBD + CABD + ABDC + ACDB + CADB + ADBC + ADCB + CDAB + DABC + DACB + DCAB >= BACD + BCAD + CBAD + BADC + BCDA + CBDA + BDAC + BDCA + CDBA + DBAC + DBCA + DCBA + 1;
s.t. AbeatsC: ABCD + ACBD + BACD + ABDC + ACDB + BADC + ADBC + ADCB + BDAC + DABC + DACB + DBAC >= BCAD + CABD + CBAD + BCDA + CADB + CBDA + BDCA + CDAB + CDBA + DBCA + DCAB + DCBA + 1;
s.t. AbeatsD: ABCD + ACBD + BACD + BCAD + CABD + CBAD + ABDC + ACDB + BADC + CADB + ADBC + ADCB >= BCDA + CBDA + BDAC + BDCA + CDAB + CDBA + DABC + DACB + DBAC + DBCA + DCAB + DCBA + 1;

# A must be eliminated in the first round and thus have more last
# preferences than any other candidate.

s.t. AlosestoB: lpA >= lpB + 1;
s.t. AlosestoC: lpA >= lpC + 1;
s.t. AlosestoD: lpA >= lpD + 1;

# A can't be a majority candidate, because then Coombs would elect
# him outright.

s.t. no_majority_violation: 2 * fpA <= v;

solve;