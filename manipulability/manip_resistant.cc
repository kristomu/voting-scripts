#include <stdint.h>
#include "voting.h"
#include "generate.h"

#include <cassert>

// Get the worst-case manipulability for a resistant set method.

manip_stats check_manipulability(size_t numvoters, size_t iterations,
	uint64_t * seed) {

	manip_stats local_manip_count;

	size_t ballots[6];

	for (size_t i = 0; i < iterations; ++i) {
		++local_manip_count.tests;

		multinomial_normal_approx(numvoters, 6,
			1/6.0, ballots, seed);

		ssize_t n = ballots[0] + ballots[1] + ballots[2] +
			ballots[3] + ballots[4] + ballots[5];

		ssize_t fpA = ballots[0] + ballots[1];
		ssize_t fpB = ballots[2] + ballots[3];
		ssize_t fpC = n - fpA - fpB;

		ssize_t BoverA = ballots[2] + ballots[3] + ballots[5];
		ssize_t AoverB = n - BoverA;

		ssize_t AoverC = ballots[0] + ballots[1] + ballots[2];
		ssize_t CoverA = n - AoverC;

		ssize_t BoverC = ballots[0] + fpB;
		ssize_t CoverB = n - BoverC;

		// Determine which candidates disqualify which others.
		// A disqualifies B if fpA > n/3 and A beats B pairwise.
		// The pattern is the same for the other candidates.
		bool AdisqB = (3 * fpA > n) && (AoverB > BoverA);
		bool AdisqC = (3 * fpA > n) && (AoverC > CoverA);
		bool BdisqA = (3 * fpB > n) && (BoverA > AoverB);
		bool BdisqC = (3 * fpB > n) && (BoverC > CoverB);
		bool CdisqA = (3 * fpC > n) && (CoverA > AoverC);
		bool CdisqB = (3 * fpC > n) && (CoverB > BoverC);

		// What candidates are members of the resistant set?
		bool A_resist = !BdisqA && !CdisqA;
		bool B_resist = !AdisqB && !CdisqB;
		bool C_resist = !AdisqC && !BdisqC;

		++local_manip_count.canonical;

		// If the resistant set has more than one candidate in it,
		// then we assume that an infinitesimal perturbation can
		// make the base method change the winner to the candidate
		// of the manipulators' choosing. It is thus manipulable.
		// (Choose B WLOG if there are three candidates).
		if (A_resist && B_resist && C_resist) {
			++local_manip_count.manip_to_B;
			continue;
		}

		if (A_resist && B_resist) {
			++local_manip_count.manip_to_B;
			continue;
		}

		if (A_resist && C_resist) {
			++local_manip_count.manip_to_C;
			continue;
		}

		if (B_resist && C_resist) {
			++local_manip_count.manip_to_C;
			continue;
		}

		// Now relabel candidates so that the sole resistant set
		// member is A, who disqualifies B.
		// TBD
		int resistant_member = -1, disqualifies = -1;

		if (A_resist) {
			resistant_member = 0;
			if (AdisqB) {
				disqualifies = 1;
			} else {
				disqualifies = 2;
			}
		}
		if (B_resist) {
			resistant_member = 1;
			if (BdisqA) {
				disqualifies = 0;
			} else {
				disqualifies = 2;
			}
		}
		if (C_resist) {
			resistant_member = 2;
			if (CdisqA) {
				disqualifies = 0;
			} else {
				disqualifies = 1;
			}
		}

		// The resistant set is acyclical.
		assert(resistant_member >= 0 && disqualifies >= 0);

		swap_candidates(ballots, resistant_member, 0);
		// If the resistant member was disqualifying A, what used to be
		// A has now been swapped to candidate resistant_member, so
		// swap resistant_member to B.
		if (disqualifies == 0) {
			swap_candidates(ballots, resistant_member, 1);
		} else {
			swap_candidates(ballots, disqualifies, 1);
		}

		// The booleans and aliases are now most likely invalid.
		// So calculate (those that we want) again.

		fpA = ballots[0] + ballots[1];
		fpB = ballots[2] + ballots[3];
		fpC = n - fpA - fpB;

		BoverA = ballots[2] + ballots[3] + ballots[5];
		AoverB = n - BoverA;

		AoverC = ballots[0] + ballots[1] + ballots[2];
		CoverA = n - AoverC;

		BoverC = ballots[0] + fpB;
		CoverB = n - BoverC;

		// If A~>B and A~>C, then we're strategy-proof.
		AdisqB = (3 * fpA > n) && (AoverB > BoverA);
		AdisqC = (3 * fpA > n) && (AoverC > CoverA);
		BdisqC = (3 * fpB > n) && (BoverC > CoverB);

		if (AdisqB && AdisqC) {
			continue;
		}

		// Otherwise we have A~>B and B~>C. Make sure.
		assert(AdisqB && BdisqC);

		// In this case C>A voters can try to break B~>C
		// to introduce C into the resistant set, after which
		// we assume a small perturbation fools the base method.

		// This is possible by BCA voters either trying to lower
		// B's first preferences:
		//		fpB - BCA < 1/3
		// or flip B>C to C>B:
		//		C>B + BCA > B>C - BCA

		ssize_t BCA = ballots[3];

		if ((3 * (fpB - BCA) < n) || (CoverB + BCA > BoverC - BCA)) {
			++local_manip_count.manip_to_C;
		}
	}

	return local_manip_count;
}