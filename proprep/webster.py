from scipy.optimize import brentq

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

def apportion(desired_num_seats, support):
	if (desired_num_seats < 1):
		return (0, 0)

	min_divisor = sum(support)/(seats + 0.5 * len(support))
	max_divisor = sum(support)/(seats * 0.5)

	found_divisor = brentq(webster_root, min_divisor, max_divisor, 
		args=(seats, support))

	return (sum(webster(found_divisor, support)), found_divisor)

# --- #

print "Enter number of seats, followed by parties' support. Finish with CTRL+D."

seats, support = get_seats_and_support()
apportioned_num_seats, found_divisor = apportion(seats, support)

if apportioned_num_seats != seats:
	print "Could not find a divisor for the apportionment."
	print "There might be a tie somewhere or the input might be wrong."
else:
	print "Apportioned", apportioned_num_seats, "seats."
	print "Divisor is", found_divisor
	print "Apportionment:"
	for x in webster(found_divisor, support):
		print x
