// Randomness and impartial culture generation

#include <iostream>
#include <vector>
#include <cassert>
#include <cstdint>
#include <cmath>

#include "generate.h"

// https://prng.di.unimi.it/xoshiro256plusplus.c

uint64_t next(uint64_t * s) {
	const uint64_t result = rotl(s[0] + s[3], 23) + s[0];

	const uint64_t t = s[1] << 17;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = rotl(s[3], 45);

	return result;
}

double next_double(uint64_t * s) {
	uint64_t x = next(s);
	return (x >> 11) * 0x1.0p-53;
}


// ================================== STATS STUFF =========================
// Generate a random normal variable. Uses the Box-Muller transform and
// throws away one of the random values (because caching isn't that much
// faster in my case).

// The code is adapted from Wikipedia.
double rnorm(double mu, double sigma, uint64_t * seed) {
	constexpr double two_pi = 2.0 * M_PI;

	double u1, u2;
	do {
		u1 = next_double(seed);
	} while (u1 == 0);

	u2 = next_double(seed);

	double mag = sigma * sqrt(-2.0 * log(u1));
	double z0  = mag * cos(two_pi * u2) + mu;

	return z0;
}

// Generate a random binomial variable using the normal approximation
// of mean np and variance np(1-p).
size_t approx_rbinom(size_t n, double p, uint64_t * seed) {
	double variance = n * p * (1-p);

	if (p < 0 || p > 1) {
		throw std::invalid_argument("approx_rbinom: p out of bounds.");
	}

	if (variance < 10) {
		// The parameter choices make normal approximation
		// unsuitable. Signal an error.
		// TBD: Use exact methods here...
		throw std::domain_error("approx_rbinom: Normal approximation is"
			" too inaccurate.");
	}

	double y = rnorm(n*p, sqrt(variance), seed);

	// Clamp to [0, n].
	if (y < 0) {
		return 0;
	}
	if (y > n) {
		return n;
	}
	return round(y);
}

// Generate counts from a multinomial distribution with the same probability p
// of drawing from each category, based on the observation
// that we can model the first count as "heads" (number of counts from the
// first category) with probability p, and "tails" (number of counts in total
// from the other category) as 1-p.
void approx_rmultinom(size_t n, size_t k, double p,
	size_t * counts, uint64_t * seed) {

	// Validate inputs.
	if (n == 0 || k == 0) {
		throw std::invalid_argument("approx_rmultinom: n == 0 or k == 0");
	}

	// Initialize the counts.
	for (int i = 0; i < k; ++i) {
		counts[i] = 0;
	}

	size_t remaining_count_sum = n;
	double remaining_probability = 1;

	for (int i = 0; i < k-1; ++i) {
		assert(remaining_probability > 0);

		// If we've used up all our counts, we're done.
		if (remaining_count_sum == 0) {
			return;
		}

		// Get the conditional probability for category i.
		double conditional_p = p / remaining_probability;

		// Draw the next counts.
		counts[i] = approx_rbinom(remaining_count_sum,
			conditional_p, seed);

		assert(counts[i] >= 0 && counts[i] <= remaining_count_sum);

		// Update remaining counts and probability.
		remaining_count_sum -= counts[i];
		remaining_probability -= p;
	}

	// The last category gets whatever remains.
	counts[k-1] = remaining_count_sum;

	return;
}