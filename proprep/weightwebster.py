from scipy.optimize import brentq

# Like webster.py, this program apportions seats according to Webster's
# method, but it also prints the relative voting power each representative
# should have to make proportionality exact.

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

def get_vote_weight(apportionment, support, index):
	if apportionment[i] == 0:
		return 0

	return support[i]*sum(apportionment)/float(sum(support)*apportionment[i])

# --- #

print("Enter number of seats, followed by parties' support. Finish with CTRL+D.")

seats, support = get_seats_and_support()
apportioned_num_seats, found_divisor = apportion(seats, support)

if apportioned_num_seats != seats:
	print("Could not find a divisor for the apportionment.")
	print("There might be a tie somewhere or the input might be wrong.")
else:
	print("Apportioned", apportioned_num_seats, "seats.")
	print("Divisor is", found_divisor)
	print("Apportionment:")
	
	apportionment = webster(found_divisor, support)
	
	for i in range(len(apportionment)):
		num_seats = apportionment[i]
		weight = get_vote_weight(apportionment, support, i)

		if num_seats != 0:
			print("%d\t seats, each with weight %.3f" % (num_seats,
				 weight))
		else:
			print("%d\t seats" % num_seats)
