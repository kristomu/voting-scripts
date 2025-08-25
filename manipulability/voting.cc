#include <vector>
#include <cstdint>
#include <iostream>

#include "voting.h"

// ================================= VOTING STUFF =========================

int hardcoded_irv(const std::vector<size_t> & ballots) {
	size_t fpA = ballots[0] + ballots[1];
	size_t fpB = ballots[2] + ballots[3];
	size_t fpC = ballots[4] + ballots[5];

	size_t n = ballots[0] + ballots[1] + ballots[2] +
		ballots[3] + ballots[4] + ballots[5];

	size_t AoverC = ballots[0] + ballots[1] + ballots[2];
	size_t BoverA = ballots[2] + ballots[3] + ballots[5];
	size_t BoverC = ballots[0] + fpB;

	size_t AoverB = n - BoverA;
	size_t CoverA = n - AoverC;
	size_t CoverB = n - BoverC;
	
	if (fpA < fpB && fpA < fpC) {
		// B vs C
		if (BoverC > CoverB) { return 1; }
		return 2;
	}
	if (fpB < fpA && fpB < fpC) {
		// A vs C
		if (AoverC > CoverA) { return 0; }
		return 2;
	}

	if (fpC < fpA && fpC < fpB) {
		// A vs B
		if (AoverB > BoverA) { return 0; }
		return 1;
	}

	throw std::runtime_error("Some ties happened");
}

// This swaps the ith and jth candidate.
void swap_candidates(size_t * ballots, size_t i, size_t j) {
	if (i > j) {
		swap_candidates(ballots, j, i);
		return;
	}

	if (i == j) {
		return;
	}

	// Swapping A and B
	//	from	idx		to	idx
	//	ABC		0		BAC	2
	//	ACB		1		BCA	3
	//	BAC		2		ABC	0
	//	BCA		3		ACB	1
	//	CAB		4		CBA	5
	//	CBA		5		CAB	4

	if (i == 0 && j == 1) {
		std::swap(ballots[0], ballots[2]);
		std::swap(ballots[1], ballots[3]);
		std::swap(ballots[4], ballots[5]);
		return;
	}

	// Swapping A and C
	// from		idx		to	idx
	//	ABC		0		CBA	5
	//	ACB		1		CAB	4
	//	BAC		2		BCA	3
	//	BCA		3		BAC	2
	//	CAB		4		ACB	1
	//	CBA		5		ABC	0

	if (i == 0 && j == 2) {
		std::swap(ballots[0], ballots[5]);
		std::swap(ballots[1], ballots[4]);
		std::swap(ballots[2], ballots[3]);
		return;
	}

	// Swapping B and C
	// from		idx		to	idx
	//	ABC		0		ACB	1
	//	ACB		1		ABC	0
	//	BAC		2		CAB	4
	//	BCA		3		CBA	5
	//	CAB		4		BAC	2
	//	CBA		5		BCA	3

	if (i == 1 && j == 2) {
		std::swap(ballots[0], ballots[1]);
		std::swap(ballots[2], ballots[4]);
		std::swap(ballots[3], ballots[5]);
		return;
	}

	std::cout << i << ", " << j << std::endl;

	throw std::invalid_argument("swap_candidates: candidate "
		"indices out of bounds");
}
