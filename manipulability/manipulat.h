#pragma once

#include <stdint.h>

manip_stats check_manipulability(size_t numvoters, size_t iterations,
	uint64_t * seed);