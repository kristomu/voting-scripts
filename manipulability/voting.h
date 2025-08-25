// Voting methods, auxiliary methods, and manipulation stats.

#pragma once

#include <vector>
#include <cstdint>
#include <iostream>

class manip_stats {
	public:
		size_t tests = 0;		// Number of elections tested.
		size_t canonical = 0;	// Number of elections where candidates are in
								//		canonical order (for IRV: A wins,
								//		B is the plurality loser).
		size_t manip_to_B = 0;	// Number of elections where strategy can make B win.
		size_t manip_to_C = 0;	// Number of elections where strategy can make C win.

		manip_stats & operator+= (const manip_stats & b) {
			tests += b.tests;
			canonical += b.canonical;
			manip_to_B += b.manip_to_B;
			manip_to_C += b.manip_to_C;

		return *this;
	}

	void print() {
		std::cout << canonical << "\t\t" << (double)(manip_to_B + manip_to_C)/canonical << "\n";
	}

	void print_data() {
		std::cout << "can: " << canonical << "\tto B: " << manip_to_B << "\tto C: " << manip_to_C << "\n";
	}
};

// Returns the winning candidate number. If any ties are encountered,
// the function will signal this with an exception.
int hardcoded_irv(const std::vector<size_t> & ballots);

// This swaps the ith and jth candidate.
void swap_candidates(size_t * ballots, size_t i, size_t j);