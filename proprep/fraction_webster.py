from fractions import Fraction
from os.path import commonprefix # Is this too ugly???

# Like webster.py, but this one uses rational numbers and finds the
# simplest divisor.

def webster(divisor, party_support):
	return [int(round(x/divisor)) for x in party_support]

def webster_root(divisor, target, party_support):
	return target - sum(webster(divisor, party_support))

def get_seats_and_support():
	seats, support = 0, []
	try:
		seats, support = int(input()), []
		while 1 == 1:
			support.append(int(input()))
	except EOFError:
		return seats, support

# Binary search root finding.
# Left is the lower bound and right is the upper. These must have different
# signs. Args give further arguments to the function we're testing.
# The lower_bound returns the point just after where the function
# changes from <0 to 0, and the upper_bound returns the point just before
# the function changes from 0 to >0.
# The binary_search function returns these values in sorted order, so the
# first is always the smaller.

def binary_search_lower_bound(func, left, right, args, tolerance=1e-6):
	last_good = None

	# TODO: Filter on tolerance of result???
	while (right-left > tolerance or last_good == None):
		middle = left + (right - left)/2
		function_result = func(middle, *args)

		if (function_result < 0):
			left = middle
		else:
			right = middle

		if (function_result == 0):
			last_good = middle

	return last_good

def binary_search_upper_bound(func, left, right, args, tolerance=1e-6):
	last_good = None

	while (right-left > tolerance or last_good == None):
		middle = left + (right - left)/2
		function_result = func(middle, *args)

		if (function_result <= 0):
			left = middle
		else:
			right = middle

		if (function_result == 0):
			last_good = middle

	return last_good

# Returns lower and upper bounds.

def binary_search(func, left, right, args, tolerance=1e-6):
	lower = binary_search_lower_bound(func, left, right, args, tolerance)
	upper = binary_search_upper_bound(func, left, right, args, tolerance)

	return (min(lower, upper), max(lower, upper))

#---#

# Find the simplest fraction within an interval by using a continued
# fraction algorithm.

def improper_fraction_to_mixed(fraction):
	integer_part = fraction.numerator//fraction.denominator

	return (integer_part, fraction-integer_part)

# Transform a fraction to a continued one.
def get_continued_fraction(fraction):
	remainder = fraction
	cf_list = []

	while(remainder != 0):
		mixed_fraction = improper_fraction_to_mixed(remainder)
		cf_list.append(mixed_fraction[0])
		if mixed_fraction[1] != 0:
			remainder = 1/mixed_fraction[1]
		else:
			remainder = 0

	return cf_list

# To test: give it [3, 7, 16] and you should get 355/113
# There is a left-to-right algorithm for this, but I don't know it.
def get_ordinary_fraction(continued_fraction):
	output_fraction = Fraction(0, 1)

	# Travel from the end up to the beginning
	for i in range(len(continued_fraction)-1, -1, -1):
		output_fraction = output_fraction + continued_fraction[i]
		if i != 0:
			output_fraction = 1 / output_fraction

	return output_fraction

# The bounds are inclusive, so this will find the shortest x/y so that
# lower <= x/y <= upper.
def get_simplified_fraction(lower, upper):
	lower_continued_fraction = get_continued_fraction(lower)
	upper_continued_fraction = get_continued_fraction(upper)

	common_prefix = commonprefix([lower_continued_fraction, 
		upper_continued_fraction])

	# Construct simplest fraction
	# https://en.wikipedia.org/wiki/Continued_fraction#Best_rational_within_an_interval
	simplest_continued_fraction = common_prefix
	if len(simplest_continued_fraction) < len(lower_continued_fraction):
		next_term = min(lower_continued_fraction[len(common_prefix)],
			upper_continued_fraction[len(common_prefix)]) + 1

		simplest_continued_fraction.append(next_term)

	return get_ordinary_fraction(simplest_continued_fraction)

def apportion(desired_num_seats, support):
	if (desired_num_seats < 1):
		return (0, 0)

	min_divisor = Fraction(sum(support), desired_num_seats + Fraction(len(support), 2))
	max_divisor = Fraction(sum(support), Fraction(desired_num_seats, 2))

	found_divisor_interval = binary_search(webster_root, min_divisor, 
		max_divisor, args=(desired_num_seats, support))

	found_divisor = get_simplified_fraction(*found_divisor_interval)

	return (sum(webster(found_divisor, support)), found_divisor)

# --- #

print("Enter number of seats, followed by parties' support. Finish with CTRL+D.")

seats, support = get_seats_and_support()
apportioned_num_seats, found_divisor = apportion(seats, support)
print(apportioned_num_seats)

if apportioned_num_seats != seats:
	print("Could not find a divisor for the apportionment.")
	print("There might be a tie somewhere or the input might be wrong.")
else:
	print("Apportioned", apportioned_num_seats, "seats.")
	print("Divisor is", found_divisor)
	print("Apportionment:")
	for x in webster(found_divisor, support):
		print(x)