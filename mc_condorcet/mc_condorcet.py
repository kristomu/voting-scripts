import random
import numpy as np
import scipy as sp

# Markov Chain Condorcet
# Choose an initial candidate at random. Then, as many times as you'd like:
#	Let the current candidate be X.
#	Pick some other candidate Y at random. If he beats the current one,
#		transition to him with probability p = d[Y, X]/numvoters,
#		(probability 1-p of staying where you are)
# The candidate you spend most time at is the winner.

# Raw Condorcet matrix.
# Row beats column, so 65 voters prefer A>B. 35 voters B>A.
cm = [ [0, 65, 40, 60], 
	   [35, 0, 75, 60], 
	   [60, 25, 0, 60],
	   [40, 40, 40, 0]]

cm_numcands = 100

# WV
def d(matrix, x, y):
	if cm[x][y] > cm[y][x]:
		return cm[x][y]
	return 0

# WV matrix from Condorcet matrix
def d_mass(matrix):
	return matrix * (matrix-np.transpose(matrix) > 0)

def evaluate_stochastically(matrix, numvoters, iterations):
	numcands = len(matrix)
	hits = [0]*numcands

	candidate = random.randint(0, numcands-1)

	for x in xrange(iterations):
		hits[candidate] += 1
		next_candidate = random.randint(0, numcands-1)
		transition_probability = d(matrix, next_candidate, candidate)/float(numvoters)
		if random.random() < transition_probability:
			candidate = next_candidate

	return np.array(hits)/float(sum(hits))

def get_markov_matrix(cond_matrix, numvoters, verbose=False):
	numcands = len(cond_matrix)
	wv_matrix = d_mass(np.array(cond_matrix))

	wv_transpose = np.transpose(wv_matrix)/float(numvoters)

	if verbose:
		print wv_transpose

	probabilities = np.transpose(wv_matrix/float(numvoters*numcands))

	for i in xrange(numcands):
		probabilities[i][i] = 1 - np.sum(probabilities[i])

	return probabilities

# function that evaluates a generic Markov chain equivalent of the process
# above. Should return the same as the function above.
def evaluate_stoch_intermed(matrix, numvoters, iterations, verbose=False):
	numcands = len(matrix)
	hits = [0]*numcands

	candidate = random.randint(0, numcands-1)

	probabilities = get_markov_matrix(matrix, numvoters, verbose)

	for x in xrange(iterations):
		hits[candidate] += 1
		roulette = random.random()
		cand = -1
		cumul = 0
		for i in xrange(numcands-1):
			if cand == -1 and cumul + probabilities[candidate][i] >= roulette:
				cand = i
			else:
				cumul += probabilities[candidate][i]
		if cand == -1:
			cand = numcands-1

		candidate = cand

	return np.array(hits)/float(sum(hits))

def evaluate_mc(matrix, numvoters, verbose=False):
	# Find the principal eigenvector of the Markov matrix with
	#	p(i,j) = d[j, i]/(numvoters * numcands)
	#	p(i,i) = what's left over for that row, 
	#		i.e. 1 - (sum over all j: d[j,i])/(numvoters*numcands)

	# Might not be ergodic! E.g. Condorcet cycle A>B>C>A has period 3. 
	# But there's always a nonzero p(i,i) in a cycle, so scratch that.

	probabilities = get_markov_matrix(matrix, numvoters, verbose)

	# why transpose?

	w, v = np.linalg.eig(np.transpose(probabilities))

	if verbose:
		print "---"

		print "Eigenvectors", abs(w)
		print "Eigenvalues:", abs(v)

		print "---"

	# Get the first eigenvector (associated with principal eigenvalue)
	# But why doesn't this sum to 1? Unnormalized eigenvector?
	pe = v[:,0]
	return abs(pe)/sum(abs(pe))

def evaluate_powermethod(matrix, numvoters, iters=100, tolerance=1e-15):

	probabilities = get_markov_matrix(matrix, numvoters, False)

	for i in xrange(iters):
		probabilities = np.dot(probabilities, probabilities)
		
		variance = sum((probabilities[0,:] - probabilities[1,:])**2)/float(numvoters)

		if variance < tolerance**2:		# same as sqrt(variance) < tolerance
			return probabilities[0,:]

	return None # no convergence


def prettyprint(string, list_in):
	print string,
	print "%.7f "*len(list_in) % tuple(list_in)

print "Scores for each candidate:"
prettyprint("Stochastic evaluation:  ", evaluate_stochastically(cm, cm_numcands, 1000000))
prettyprint("Intermediate stochastic:", evaluate_stoch_intermed(cm, cm_numcands, 1000000))
prettyprint("Analytical evaluation:  ", abs(evaluate_mc(cm, cm_numcands)))
prettyprint("Power method evaluation:", evaluate_powermethod(cm, cm_numcands))