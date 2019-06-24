#include "examplelib.h"
#include <stdarg.h>

int32_t examplelib_f1(int32_t a, int32_t b, int32_t * c) {
    *c = a + b;
    return 0xcafe;
}

int32_t examplelib_vf1(unsigned int count, ...) {
    int32_t sum = 0;

    va_list p;
    va_start(p, count);

    for (unsigned int index = 0; index < count; index++) {
        sum += va_arg(p, int32_t);
    }

    va_end(p);

    return sum;
}

int32_t examplelib_callback(int32_t (*callback)(int32_t a, int32_t b)) {
    return callback(123, 456);
}
