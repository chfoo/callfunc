#pragma once

#include <stdint.h>
#include <stdbool.h>
#include <ffi.h>

#ifdef _WIN32
    #include <windows.h>
#else
    #include <dlfcn.h>
#endif

#ifdef CALLFUNC_HL
    #define HL_NAME(n) n
    #include <hl.h>
    #define CALLFUNC_API HL_PRIM
#else
    #define CALLFUNC_API
#endif

#define CALLFUNC_SUCCESS (0)
#define CALLFUNC_FAILURE (1)

#define CALLFUNC_MAX_RETURN_SIZE (8)

#define CALLFUNC_VOID (0)
#define CALLFUNC_UINT8 (1)
#define CALLFUNC_SINT8 (2)
#define CALLFUNC_UINT16 (3)
#define CALLFUNC_SINT16 (4)
#define CALLFUNC_UINT32 (5)
#define CALLFUNC_SINT32 (6)
#define CALLFUNC_UINT64 (7)
#define CALLFUNC_SINT64 (8)
#define CALLFUNC_FLOAT (9)
#define CALLFUNC_DOUBLE (10)
#define CALLFUNC_UCHAR (11)
#define CALLFUNC_SCHAR (12)
#define CALLFUNC_USHORT (13)
#define CALLFUNC_SSHORT (14)
#define CALLFUNC_SINT (15)
#define CALLFUNC_UINT (16)
#define CALLFUNC_SLONG (17)
#define CALLFUNC_ULONG (18)
#define CALLFUNC_POINTER (19)

#define CALLFUNC_DEFAULT_ABI (-999)

#define _CALLFUNC_ABORT_NULL(pointer) { assert(pointer != NULL); if (pointer == NULL) { abort(); } }

#ifdef __cplusplus
extern "C" {
#endif

typedef int CallfuncError;

struct CallfuncLibrary {
    void * library;
};

struct CallfuncFunction {
    struct CallfuncLibrary * library;
    ffi_cif cif;
    void(*function)(void);
};

struct CallfuncStructType {
    ffi_type type;
};

CALLFUNC_API
const char * callfunc_get_error_message();

CALLFUNC_API
void callfunc_get_sizeof_table(uint8_t * buffer);

CALLFUNC_API
void * callfunc_alloc(size_t size, bool zero);

CALLFUNC_API
void callfunc_free(void * pointer);

CALLFUNC_API
struct CallfuncLibrary * callfunc_new_library();

CALLFUNC_API
void callfunc_del_library(struct CallfuncLibrary * library);

CALLFUNC_API
CallfuncError callfunc_library_open(struct CallfuncLibrary * library,
    const char * name);

CALLFUNC_API
void callfunc_library_close(struct CallfuncLibrary * library);

CALLFUNC_API
CallfuncError callfunc_library_get_address(struct CallfuncLibrary * library,
    const char * name, void ** dest_pointer);

CALLFUNC_API
struct CallfuncFunction * callfunc_new_function(
    struct CallfuncLibrary * library);

CALLFUNC_API
void callfunc_del_function(struct CallfuncFunction * function);

CALLFUNC_API
CallfuncError callfunc_function_define(struct CallfuncFunction * function,
    void * target_function, int abi, uint8_t * definition);

CALLFUNC_API
void callfunc_function_call(struct CallfuncFunction * function,
    uint8_t * argument_buffer);

CALLFUNC_API
struct CallfuncStructType * callfunc_new_struct_type();

CALLFUNC_API
void callfunc_del_struct_type(struct CallfuncStructType * struct_type);

CALLFUNC_API
CallfuncError callfunc_struct_type_define(
    struct CallfuncStructType * struct_type, uint8_t * definition,
    uint8_t * resultInfo);

CALLFUNC_API
int64_t callfunc_pointer_to_int64(void * pointer);

CALLFUNC_API
void * callfunc_int64_to_pointer(int64_t address);

CALLFUNC_API
void callfunc_pointer_get(void * pointer, uint8_t data_type, uint8_t * buffer,
    int32_t offset);

CALLFUNC_API
void callfunc_pointer_set(void * pointer, uint8_t data_type, uint8_t * buffer,
    int32_t offset);

size_t _callfunc_data_type_size(uint8_t data_type);

ffi_type * _callfunc_constant_to_ffi_type(int constant);

const char * _callfunc_get_dll_error_message();

CallfuncError _check_ffi_status(ffi_status status);

#ifdef __cplusplus
}
#endif
