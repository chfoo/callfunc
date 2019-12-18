#pragma once

#include <stdint.h>

#include "../../../out/examplelib/examplelib_Export.h"

#ifdef __cplusplus
extern "C" {
#endif

struct examplelib_struct1 {
    char a;
    int32_t b;
    double c;
};

examplelib_EXPORT int32_t examplelib_ints(int32_t a, int32_t b, int32_t * c);
examplelib_EXPORT const char * examplelib_string(const char * text);
examplelib_EXPORT int32_t examplelib_variadic(unsigned int count, ...);
examplelib_EXPORT int32_t examplelib_callback(int32_t (*callback)(int32_t a, int32_t b));
examplelib_EXPORT struct examplelib_struct1 examplelib_struct_value(struct examplelib_struct1 value);

#ifdef __cplusplus
}
#endif
