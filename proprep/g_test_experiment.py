# Tests to evaluate D'Hondt vs Sainte Laguë as an approximation
# to the multinomial mode and by the G-test.

# This suggests that SL optimizes the G-test measure (and thus the
# KL divergence under integer seat constraints), which I'd expected
# given the relation between the Sainte-Laguë index and the chi-square
# test, and the latter to the G-test. But it still remains to be proven.

# I'm not entirely sure what to make of D'Hondt being closer to optimal
# by multinomial pmf. I seem to recall the reason having something to do
# with the relation of likelihood functions to the pmf, and varying
# constants of proportionality. But I can't find the document where I
# reasoned about this last time...

# I could always just skip the middle man and use the chi-squared "test"
# (index) directly.

import scipy.stats
from scipy.optimize import brentq

import numpy as np

# from webster.py

def div_method(divisor, party_support, rounding_funct):
	return [int(rounding_funct(x/divisor)) for x in party_support]

def div_method_root(divisor, target, party_support, rounding_funct):
	return target - sum(div_method(divisor, party_support, rounding_funct))

def get_seats_and_support():
	seats, support = 0, []
	try:
		seats, support = int(input()), []
		while 1 == 1:
			support.append(int(input()))
	except EOFError:
		return seats, support

def apportion(desired_num_seats, support, rounding_funct):
	if (desired_num_seats < 1):
		return (0, 0)

	min_divisor = sum(support)/(desired_num_seats + len(support))
	max_divisor = sum(support)#/(desired_num_seats * 0.5)

	set_div_method_root = lambda divisor, target, party_support: div_method_root(
		divisor,target,  party_support, rounding_funct)

	found_divisor = brentq(set_div_method_root, min_divisor, max_divisor, 
		args=(desired_num_seats, support))

	apportionment = div_method(found_divisor, support, rounding_funct)

	return (apportionment, sum(apportionment), found_divisor)

# -- G-test stuff

# calculate observed * ln(observed/expected) with the
# convention that 0 ln 0 = 0.

def G_test_component(observed, expected):
	if observed == 0: return 0
	return observed * np.log(observed/expected)

def G_test(support, apportionment):
	# Normalize fractions to have total probability one.
	observed = np.array(apportionment)/np.sum(apportionment)
	expected = support/sum(support)

	G_test_sum = 0

	for observed_i, expected_i in zip(observed, expected):
		G_test_sum += 2 * G_test_component(observed_i, expected_i)

	return G_test_sum

# For tests, higher is better, while for the G-test, smaller is better.
# So return the negative.
def G_test_eval(num_seats, support, apportionment):
	if num_seats != sum(apportionment):
		raise Exception("G-test: Invalid apportionment!")

	return -G_test(support, apportionment)

# testing.

# D'Hondt seems to always beat Sainte-Laguë by multinomial log pmf.
# But by the G test?

def logpmf(num_seats, support, apportionment):
	if num_seats != sum(apportionment):
		raise Exception("Log-pmf: Invalid apportionment!")

	rv = scipy.stats.multinomial(num_seats, support)

	return rv.logpmf(apportionment)

def print_apportionment_records(rounds=1000, evaluate=logpmf):
	dh_beats_sl = 0
	sl_beats_dh = 0

	for i in range(rounds):
		seats = np.random.randint(2, 2**np.random.randint(2, 8))
		parties = np.random.randint(2, 10)

		support = np.random.uniform(size=parties)
		support /= sum(support)

		sainte_lague = apportion(seats, support, np.round)
		d_hondt = apportion(seats, support, np.floor)

		dh = evaluate(seats, support, d_hondt[0])
		sl = evaluate(seats, support, sainte_lague[0])
		if dh > sl:
			dh_beats_sl += 1
		if sl > dh:
			sl_beats_dh += 1

	print(" %d tests. D'Hondt won %d times, Sainte-Laguë %d times." % (rounds,
		dh_beats_sl, sl_beats_dh))

print("log pmf")
print_apportionment_records(rounds=10000, evaluate=logpmf)
print("G-test")
print_apportionment_records(rounds=10000, evaluate=G_test_eval)