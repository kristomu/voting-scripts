#include <stdint.h>
#include "voting.h"
#include "generate.h"

manip_stats check_manipulability(size_t numvoters, size_t iterations,
	uint64_t * seed) {

	manip_stats local_manip_count;

	size_t ballots[6];

	for (size_t i = 0; i < iterations; ++i) {
		++local_manip_count.tests;

		approx_rmultinom(numvoters, 6,
			1/6.0, ballots, seed);

		ssize_t n = ballots[0] + ballots[1] + ballots[2] +
			ballots[3] + ballots[4] + ballots[5];

		ssize_t fpA = ballots[0] + ballots[1];
		ssize_t fpB = ballots[2] + ballots[3];
		ssize_t fpC = n - fpA - fpB;
		ssize_t AoverC = ballots[0] + ballots[1] + ballots[2];
		ssize_t CoverA = n - AoverC;

		// Relabel the candidates so that
		// A beats C pairwise, and
		// B is the Plurality loser

		if (fpB > fpC) {
			swap_candidates(ballots, 1, 2);

			fpB = ballots[2] + ballots[3];
			fpC = n - fpA - fpB;
			AoverC = ballots[0] + ballots[1] + ballots[2];
			CoverA = n - AoverC;
		}

		if (fpB > fpA) {
			swap_candidates(ballots, 0, 1);

			fpA = ballots[0] + ballots[1];
			fpB = ballots[2] + ballots[3];

			AoverC = ballots[0] + ballots[1] + ballots[2];
			CoverA = n - AoverC;
		}

		if (CoverA > AoverC) {
			swap_candidates(ballots, 0, 2);

			fpA = ballots[0] + ballots[1];
			fpC = n - fpA - fpB;
			AoverC = ballots[0] + ballots[1] + ballots[2];
			CoverA = n - AoverC;
		}

		if (!((fpC >= fpB) && (fpA >= fpB) && (AoverC >= CoverA))) {
			throw std::logic_error("Preconditions not met despite rearranging!");
		}

		ssize_t BoverA = ballots[2] + ballots[3] + ballots[5];
		ssize_t BoverC = ballots[0] + fpB;
		ssize_t CBA = ballots[5];
		ssize_t BCA = ballots[3];

		ssize_t AoverB = n - BoverA;
		ssize_t CoverB = n - BoverC;

		if (!((fpC > fpB) && (fpA > fpB) && (AoverC > CoverA))) {
			/*if ((fpC >= fpB)) { std::cout << "One\n"; }
			if ((fpA >= fpB)) { std::cout << "Two\n"; }
			if ((AoverC >= CoverA)) { std::cout << "Three\n"; }
			std::cout << fpA << ", " << fpB << ", " << fpC << std::endl;
			std::cout << AoverC << ", " << CoverA << std::endl;
			throw std::invalid_argument("Oops!");*/
			continue;
		}

		++local_manip_count.canonical;

		// Can CBA voters all vote BCA to make the contest A vs B, and
		// would B then win?
		if ((fpB + CBA > fpC - CBA) && (BoverA > AoverB)) {
			// If so, manipulable.
			++local_manip_count.manip_to_B;
			continue;
		}

		// Can C voters donate to B so that the top two become B and C?
		if ( (fpC > fpA) && (fpB + fpC > 2 * fpA + 1)) {
			// If shifting CBA to BCA makes B beat C outright, then
			// that's a manip. towards B.
			if ((CoverB < 2 * (fpC - fpA - 1) + BoverC) && (CBA >= (fpC - fpA - 1))) {
				++local_manip_count.manip_to_B;
				continue;
			}

			// If shifting C-first to B kicks A off and C wins after,
			// then that's a manip to C. (pushover)
			if (CoverB >= 2 * (fpC - fpA - 1) + BoverC) {
				++local_manip_count.manip_to_C;
			}
		}
	}

	return local_manip_count;
}
