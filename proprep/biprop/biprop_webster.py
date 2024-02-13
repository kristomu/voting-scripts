# coding=utf-8

# Biproportional apportionment: let there be n parties and m regions, and
# let a party x's support in region y be v_xy. Let the sum of seats for 
# region t be

# sr_t = sum k=1...n 	round(v_kt * r_t * p_k)
# and the sum of seats for party q be
# sp_q = sum k=1...m 	round(v_qk * r_k * p_q)

# where r_1...r_m are the region multipliers and p_1...p_n are the party
# multipliers.

# Then, given desired region and party sums R_1..R_m, P_1...P_m, alternate
# 	adjusting r_1...r_m so that sr_t=D_t for all t.
#	adjusting p_1...p_n so that sp_q=P_q for all q.

# I.e.: assign each region a region weight and each party a party
# weight. Then alternatedly adjust region and party weights to make
# apportionments of weighted support give the number of seats desired for 
# each region and vice versa.

# ==========================================================================

# This idea might be generalizable to my Bucklin/facility location problem
# method. It might also be generalizable to methods that pass mono-raise if
# we let increasing the party mulitplier mean more and more voters's ranking
# of candidates from party X are raised.

import numpy as np
from scipy.optimize import brentq

# 1D apportionment code. This code would send Robert to cloud nine.

# CORE APPORTIONMENT FUNCTION. round() means Webster/Sainte-Laguë. 
# Use floor() for Jefferson/D'Hondt or ceil() for Adams. Huntington-Hill is
# more complex.
# Note: this must be vectorizable in the numpy sense!
def apportion(votes, factor):
	return np.round(votes * factor)

#---

def numseats(votes, factor):
	return sum(apportion(votes, factor))

def compare_seats_fun(votes, desired_num_seats):
	return lambda factor: numseats(votes, factor)-desired_num_seats

def get_factor(votes, desired_num_seats):
	# TODO: better bounds, but this might be all we can do if we're not
	# sure about what rounding method will be used.
	return brentq(compare_seats_fun(votes, desired_num_seats),
		0, 2)

def get_apportionment(votes, desired_num_seats):
	return apportion(votes, get_factor(votes, desired_num_seats))

# 2D apportionment code. This is written from a region point of view;
# the party adjustment is the same, just with party and region factors
# switched and with a 90 deg rotated count matrix. 

# We have current party and region factors and we want to alter the region
# factors so that we get the right number of seats in each region. 
# We can do so by doing an apportionment region by region and 
# noting down the factor this apportionment finds.

# That is, for region A, we want to find y so that
# (SUM i=1..n: f(x_i * party_1_factor * y)) = num seats for A

# which is the same as finding the apportionment factor for
# [x_1 * party_1_factor, ..., x_n * party_n_factor], and then 
# the new factor for region A is y.

def get_adjusted_factors(counts, region_seats, party_factors):

	region_adjustments = []

	for (local_party_counts, local_seat_target) in zip(counts, 
		region_seats):

		region_adjustments.append(get_factor(local_party_counts * 
			party_factors, local_seat_target))

	return np.array(region_adjustments)

def get_biproportional_apportionment(counts, row_seats, column_seats,
	row_factors, column_factors):

	# Multiply by row and column factors
	quantized = counts * column_factors
	quantized = np.transpose(np.transpose(quantized)*row_factors)

	# Now just apply the apportionment rounding procedure and return.
	return apportion(quantized, 1).astype(int)

# Returns true if both the row and column constraints (seats per party 
# and seats per region) are met, otherwise false.
def check_validity(counts, row_seats, column_seats, row_factors,
	column_factors):

	# Get the apportionment
	quantized = get_biproportional_apportionment(counts, row_seats,
		column_seats, row_factors, column_factors)

	# Get the sum of mean absolute deviation of columns
	allocated_col_seats = sum(quantized)
	allocated_row_seats = sum(np.transpose(quantized))

	return np.all(allocated_row_seats == row_seats) and \
			np.all(allocated_col_seats == column_seats)

def get_biproportional_factors(counts, row_seats, column_seats):
	# Alternate between adjusting row (party) and column (region)
	# factors until both apportionments match.

	row_factors = np.ones(np.shape(counts)[0])
	column_factors = np.ones(np.shape(counts)[1])

	while True:
		column_factors = get_adjusted_factors(np.transpose(counts),
			column_seats, row_factors)
		row_factors = get_adjusted_factors(counts, row_seats,
			column_factors)

		if check_validity(counts, row_seats, column_seats, row_factors, 
			column_factors):
		
			return row_factors, column_factors

# -- MAIN --

# Regions across columns, parties down rows if [row][col]
# Example from Wikipedia: https://en.wikipedia.org/w/index.php?title=Biproportional_apportionment&oldid=705022098

counts = np.array([	[123, 45, 815], 
			[912, 714, 414], 
			[312, 255, 215]	])

#party_names = ["A", "B", "C"]
#region_names = ["I", "II", "III"]

seats = 20

# First find the upper apportionments for regions and parties.
# (This could be done exogeneously if so desired, i.e. the method
#  should work for arbitrary upper apportionments, so it's easy to add 
#  thresholds or whatnot.)

region_sums = sum(counts)
party_sums = sum(np.transpose(counts))

region_seats = get_apportionment(region_sums, seats)	# R_1...R_m
party_seats = get_apportionment(party_sums, seats)	# P_1...P_n

# Now start the adjustment
party_factors, region_factors = get_biproportional_factors(
	counts, party_seats, region_seats)

print("--")

print("Biproportional apportionment:")
print(get_biproportional_apportionment(counts, party_seats,
	region_seats, party_factors, region_factors))

print("Seats per region:")
print(region_seats)
print("Seats per party:")
print(party_seats)
