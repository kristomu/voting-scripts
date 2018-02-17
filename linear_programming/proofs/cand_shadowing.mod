# Construct a scenario where BTV isn't monotone due to a "candidate shadowing"
# effect.

# The plan is to initially have B win and then E win.
# Then someone raises B>E to E>B, which costs B his victory, thus leading to
# A winning and subsequently C winning.

param num_to_raise := 2;	# number of ABE ballots to raise E on

param numvoters := 3000;
param droop_quota := numvoters / 3;
# Alas, these need to be set manually.
param num_b_voters := droop_quota+5;
param num_a_voters := num_b_voters-1;

# because these can't be unknowns
param Afac := (num_a_voters - droop_quota)/droop_quota;
param Bfac := (num_b_voters - droop_quota)/droop_quota;

var v_AB >= 0 integer;
var v_ABE >= 0 integer;
var v_A >= 0 integer;
var v_AE >= 0 integer;
var v_AEB >= 0 integer;
var v_BA >= 0 integer;
var v_BC >= 0 integer;
var v_C >= 0 integer;
var v_E >= 0 integer;

var fpA >= 0 integer;
var fpB >= 0 integer;
var fpC >= 0 integer;
var fpE >= 0 integer;

var spA >= 0 integer;
var spB >= 0 integer;
var spC >= 0 integer;
var spE >= 0 integer;

var spAnew >= 0 integer;
var spBnew >= 0 integer;
var spCnew >= 0 integer;
var spEnew >= 0 integer;

var AscoreAfterB >= 0;
var CscoreAfterB >= 0;
var EscoreAfterB >= 0;

var BscoreAfterA >= 0;
var CscoreAfterA >= 0;
var EscoreAfterA >= 0;

maximize opt: 0;	# Doesn't matter

s.t. numvoters_constraint:
	v_AB + v_ABE + v_A + v_AE + v_AEB + v_BA + v_BC + v_C + v_E = 
		numvoters;

s.t. def_fpA:
	fpA = v_AB + v_ABE + v_A + v_AE + v_AEB;
s.t. def_fpB:
	fpB = v_BA + v_BC;
s.t. def_fpC:
	fpC = v_C;
s.t. def_fpE:
	fpE = v_E;

s.t. def_spA:
	spA = v_BA;
s.t. def_spB:
	spB = v_AB + v_ABE;
s.t. def_spC:
	spC = v_BC;
s.t. def_spE:
	spE = v_AEB + v_AE;

s.t. num_A_voters_constraint:
	fpA + spA = num_a_voters;
s.t. num_B_voters_constraint:
	fpB + spB = num_b_voters;

s.t. equal_a_and_b_first_round:
	fpA = fpB;
s.t. b_beats_c_first_round:
	fpB >= fpC + 1;
s.t. b_beats_e_first_round:
	fpB >= fpE + 1;
s.t. b_doesnt_exceed_droop_first_round:
	droop_quota >= fpB;

s.t. b_exceeds_droop_second_round:
	fpB + spB >= droop_quota + 1;
s.t. b_beats_a_second_round:
	fpB + spB >= fpA + spA + 1;
s.t. b_beats_c_second_round:
	fpB + spB >= fpC + spC + 1;
s.t. b_beats_e_second_round:
	fpB + spB >= fpE + spE + 1;

# After reweighting, E must win.

s.t. ASAB_def:
	AscoreAfterB = v_AB * Bfac + v_ABE * Bfac + v_A + v_AE + v_AEB + 
		v_BA * Bfac;

s.t. CSAB_def:
	CscoreAfterB = v_C + v_BC * Bfac;

s.t. ESAB_Def:
	EscoreAfterB = v_E + v_AEB + v_AE;

s.t. e_beats_a_after_b:
	EscoreAfterB >= AscoreAfterB + 0.0001;

s.t. e_beats_c_after_b:
	EscoreAfterB >= CscoreAfterB + 0.0001;

s.t. e_exceeds_droop:
	EscoreAfterB >= droop_quota + 0.0001;

s.t. e_exceeds_a_by_fp_alone:
	v_E >= v_AB * Bfac + v_ABE * Bfac + v_A + v_AE + v_AEB + 0.0001;

# raise k votes on ABE to AEB, helping E

s.t. must_have_k_votes:
	v_ABE >= num_to_raise;

s.t. def_spAnew:
	spAnew = spA;

s.t. def_spBnew:
	spBnew = v_AB + v_ABE - num_to_raise;

s.t. def_spCnew:
	spCnew = spC;

s.t. def_spEnew:
	spEnew = spE + num_to_raise;

s.t. a_is_electable_second_round_post_raise:
	fpA + spAnew >= droop_quota + 1;

s.t. a_beats_b_post_raise:
	fpA + spAnew >= fpB + spBnew + 1;

s.t. a_beats_c_post_raise:
	fpA + spAnew >= fpC + spCnew + 1;

s.t. a_beats_e_post_raise:
	fpA + spAnew >= fpE + spEnew + 1;

# After reweighting, C wins.

s.t. def_BscoreAfterA:
	BscoreAfterA = v_BA * Afac + v_BC + v_AB * Afac + v_ABE * Afac;

s.t. def_CscoreAfterA:
	CscoreAfterA = fpC + spC;

s.t. def_EscoreAfterA:
	EscoreAfterA = v_E + v_AE * Afac + (v_AEB + num_to_raise) * Afac;

s.t. c_beats_b_after_raise_reweight:
	CscoreAfterA >= BscoreAfterA + 0.00001;

s.t. c_beats_e_after_raise_reweight:
	CscoreAfterA >= EscoreAfterA + 0.00001;
