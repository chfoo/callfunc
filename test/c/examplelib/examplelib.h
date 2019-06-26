#pragma once

#include <stdint.h>

#include "../../../out/out/examplelib/examplelib_Export.h"

#ifdef __cplusplus
extern "C" {
#endif

examplelib_EXPORT int32_t examplelib_ints(int32_t a, int32_t b, int32_t * c);
examplelib_EXPORT const char * examplelib_string(const char * text);
examplelib_EXPORT int32_t examplelib_variadic(unsigned int count, ...);
examplelib_EXPORT int32_t examplelib_callback(int32_t (*callback)(int32_t a, int32_t b));

#ifdef __cplusplus
}
#endif
