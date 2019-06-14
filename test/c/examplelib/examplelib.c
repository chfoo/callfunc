#include "examplelib.h"

int32_t examplelib_f1(int32_t a, int32_t b, int32_t * c) {
    *c = a + b;
    return 0xcafe;
}
