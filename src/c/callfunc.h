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
    // we've already prefixed our names
    #define HL_NAME(n) n
    #include <hl.h>
    #define CALLFUNC_API HL_PRIM
#else
    #define CALLFUNC_API
#endif

#define CALLFUNC_API_VERSION (0x03)

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
#define CALLFUNC_STRUCT (20)

#define CALLFUNC_DEFAULT_ABI (-999)

#define _CALLFUNC_ABORT_NULL(pointer) { assert(pointer != NULL); if (pointer == NULL) { abort(); } }

#ifdef __cplusplus
extern "C" {
#endif

typedef int CallfuncError;

#ifdef CALLFUNC_CPP
    typedef Dynamic CallfuncHaxeFunc;
#elif CALLFUNC_HL
    typedef vclosure * CallfuncHaxeFunc;
#else
    typedef void (*CallfuncHaxeFunc)(uint8_t *);
#endif


struct CallfuncLibrary {
    void * library;
};

struct CallfuncFunction {
    struct CallfuncLibrary * library;
    ffi_cif cif;
    void(*function)(void);
    void ** arg_pointers;
    bool * arg_pointer_allocated;
};

struct CallfuncStructType {
    ffi_type type;
};

struct CallfuncCallback {
    ffi_cif cif;
    ffi_closure * closure;
    void * code_location;
    uint8_t * arg_buffer;
    CallfuncHaxeFunc haxe_function;
};

CALLFUNC_API
int32_t callfunc_api_version();

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
struct CallfuncCallback * callfunc_new_callback();

CALLFUNC_API
void callfunc_del_callback(struct CallfuncCallback * callback);

CALLFUNC_API
CallfuncError callfunc_callback_define(struct CallfuncCallback * callback,
    uint8_t * definition);

CALLFUNC_API
CallfuncError callfunc_callback_bind(struct CallfuncCallback * callback,
    uint8_t * arg_buffer, CallfuncHaxeFunc haxe_function);

CALLFUNC_API
void * callfunc_callback_get_pointer(struct CallfuncCallback * callback);

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

CALLFUNC_API
void callfunc_pointer_array_get(void * pointer, uint8_t data_type,
    uint8_t * buffer, int32_t index);

CALLFUNC_API
void callfunc_pointer_array_set(void * pointer, uint8_t data_type,
    uint8_t * buffer, int32_t index);

size_t _callfunc_data_type_size(uint8_t data_type);

const char * _callfunc_get_dll_error_message();

ffi_type * _callfunc_constant_to_ffi_type(int constant);

CallfuncError _check_ffi_status(ffi_status status);

void _callfunc_parse_parameter_definition(uint8_t * definition,
    size_t * num_params, int32_t * num_fixed_params,
    ffi_type *** parameter_types,
    ffi_type ** return_type);

void _callfunc_parse_struct_definition(uint8_t * definition,
    size_t * num_fields, ffi_type *** field_types);

ffi_type * _callfunc_parse_type(uint8_t * buffer, size_t offset,
    size_t * bytes_read);

void * _callfunc_get_buffer_struct_copy(uint8_t * buffer, size_t offset,
    size_t struct_size);

void _callfunc_rescursive_free_types(ffi_type ** types, size_t length);

void * _callfunc_get_aligned_pointer(void * pointer, uint8_t data_type,
    int32_t index);

void _callfunc_closure_handler(ffi_cif * cif, void * return_value,
    void ** args, void * user_data);

int32_t _callfunc_array_get_int(uint8_t * buffer, size_t offset);

void _callfunc_array_set_int(uint8_t * buffer, size_t offset, int32_t value);

void _callfunc_closure_impl(struct CallfuncCallback * callback);

#ifdef __cplusplus
}
#endif
