#include "examplelib.h"
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

int32_t examplelib_ints(int32_t a, int32_t b, int32_t * c) {
    *c = a + b;
    return 0xcafe;
}

const char * examplelib_string(const char * text) {
    char * new_string = (char *) malloc(strlen(text) + 1);

    for (size_t index = 0; index < strlen(text) + 1; index++) {
        if ('a' <= text[index] && text[index] <= 'z') {
            new_string[index] = text[index] ^ 0x20;
        } else {
            new_string[index] = text[index];
        }
    }

    return new_string;
}

int32_t examplelib_variadic(unsigned int count, ...) {
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

struct examplelib_struct1 examplelib_struct_value(struct examplelib_struct1 value) {
    struct examplelib_struct1 return_value;

    return_value.a = value.a ^ 0x20;
    return_value.b = value.b ^ 0x20;
    return_value.c = value.c * 2;

    return return_value;
}
