#include <iostream>
#include <vector>
#include <cmath>

#include <omp.h>
#include <time.h>
#include <unistd.h>

#include "voting.h"
#include "manipulat.h"

// I give up - I can't get this to be faster than 17x. It's got something
// to do with how the structures are laid out in CPU. False sharing, perhaps.

// ========================= MULTITHREADING STUFF =========================

// These variables are shared between the threads.
// This might not be the best way to do things but eh,
// whatever.
manip_stats manip_count;

// Lock for keeping the other threads from contributing
// when the output thread does a status report.
omp_lock_t count_lock;

// In number of tests per second.
size_t sequential_perf;

long double nanotime() {
	timespec tp;

	clock_gettime(CLOCK_MONOTONIC, &tp);

	int64_t ns = tp.tv_sec * (int64_t)1000000000UL
		+ tp.tv_nsec;

	return ns/1e9;
}

void do_status_report(long double start_time) {
	long double now = nanotime();

	std::cout.precision(4);
	long double elapsed = now-start_time;

	std::cout << (int)round(elapsed) << "s elapsed (";
	std::cout << manip_count.tests/(elapsed * sequential_perf) << "x) :\t";
	std::cout.precision(12);
	manip_count.print();

	std::cout.precision(4);
	std::cout << (int)round(elapsed) << "s elapsed (";
	std::cout << manip_count.tests/(elapsed * sequential_perf) << "x) :\t";
	std::cout.precision(12);
	manip_count.print_data();
}

void status_report_thread() {
	#pragma omp critical
	std::cout << "Starting status report thread..." << std::endl;

	long double start = nanotime();
	long double next_printout_time = start;
	long double seconds_to_wait = 5;

	while (true) {
		// Sleep a while to keep it from wasting power
		// checking time over and over again.
		// Wait 100ms.
		usleep(100 * 1e3);

		long double now = nanotime();

		if (now >= next_printout_time) {
			// Set the lock because we're going to print.
			omp_set_lock(&count_lock);
			do_status_report(start);
			omp_unset_lock(&count_lock);

			next_printout_time = now + seconds_to_wait;
		}
	}
}

// If timing is true, we're running this just to get an idea of
// what sequential performance is; so don't print anything.
void worker_thread(int thread_num, bool timing) {
	#pragma omp critical
	if (!timing) {
		std::cout << "Starting worker thread " << thread_num << std::endl;
	}

	size_t numvoters = 1e18;
	size_t local_iterations = 262144;

	uint64_t seed[4] = {0, 0, 0, 0};
	seed[0] = 2*thread_num + 1; // e.g.

	manip_stats local_manip_count;

	do {
		// Get manipulation counts in a batch so that we don't spend
		// too much time blocking the other threads.
		local_manip_count = check_manipulability(numvoters, local_iterations,
			seed);
		omp_set_lock(&count_lock);
		//std::cout << "Inside count lock: " << thread_num << "\n";
		manip_count += local_manip_count;
		omp_unset_lock(&count_lock);
	} while (!timing);
}

void single_threaded() {
	uint64_t seed[4] = {0, 0, 0, 0};
	seed[0] = 1;			// e.g.

	size_t numvoters = 1e18;
	size_t local_iterations = 262144;

	long double start = nanotime();
	long double next_printout_time = start;
	long double seconds_to_wait = 5;

	for (;;) {
		manip_count += check_manipulability(numvoters, local_iterations,
			seed);

		long double now = nanotime();

		if (now >= next_printout_time) {
			do_status_report(start);
			next_printout_time = now + seconds_to_wait;
		}
	}
}

int main() {
	std::cout.precision(12);
	int num_threads = omp_get_max_threads();

	std::cout << "Num threads: " << num_threads << "\n";

	std::cout << "Timing...\n";
	long double before = nanotime();
	worker_thread(0, true);
	long double after = nanotime();
	sequential_perf = manip_count.tests/(after-before);
	std::cout << "Sequential performance: " << sequential_perf << "/s.\n";
	manip_count = manip_stats();

	// For 1 billion voters, the current figures are:

	/*55455s elapsed (17.78x) :       17215347095010          0.168840473235
	  55455s elapsed (17.78x) :       can: 17215347095010     
	  							to B: 2621533493617    to C: 285113856815 */

	// 0.16884047(3)

	/*
	manip_count.canonical = 17215347095010;
	manip_count.manip_to_B = 2621533493617;
	manip_count.manip_to_C = 285113856815;*/

	// Now let's test 1e18 voters

	// Initialize lock.
	omp_init_lock(&count_lock);

	// TODO: Set up signal handler.

	// Set up parallel processing with the max number of
	// threads, plus one for status reporting.
	#pragma omp parallel num_threads(num_threads + 1)
	{
		// Each thread should have its own randomness
		// so that we don't waste the Monte-Carlo
		// calculations on the same trajectory.
		// TODO: Fix
		int thread_num = omp_get_thread_num();

		if (thread_num == 0) {
			status_report_thread();
		} else {
			worker_thread(thread_num, false);
		}
	}
}
