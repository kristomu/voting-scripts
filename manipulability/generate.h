// Randomness and impartial culture generation
#pragma once

#include <iostream>
#include <vector>
#include <cstdint>
#include <cmath>

// #include "ziggurat.hpp" // TBD

static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

uint64_t next(uint64_t * s);

double next_double(uint64_t * s);

// Stats stuff.

double rnorm(uint64_t * seed, double mu, double sigma);

size_t approx_rbinom(size_t n, double p, uint64_t * seed);

void approx_rmultinom(size_t n, size_t k, double p,
	size_t * counts, uint64_t * seed);