#include <assert.h>
#include <float.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "callfunc.h"

static const char * _callfunc_error_message;

int32_t callfunc_api_version() {
    return CALLFUNC_API_VERSION;
}

const char * callfunc_get_error_message() {
    return _callfunc_error_message;
}

void callfunc_get_sizeof_table(uint8_t * buffer) {
    buffer[0] = sizeof(uint8_t);
    buffer[1] = sizeof(int8_t);
    buffer[2] = sizeof(uint16_t);
    buffer[3] = sizeof(int16_t);
    buffer[4] = sizeof(uint32_t);
    buffer[5] = sizeof(int32_t);
    buffer[6] = sizeof(uint64_t);
    buffer[7] = sizeof(int64_t);
    buffer[8] = sizeof(float);
    buffer[9] = sizeof(double);
    buffer[10] = sizeof(unsigned char);
    buffer[11] = sizeof(signed char);
    buffer[12] = sizeof(unsigned short);
    buffer[13] = sizeof(short);
    buffer[14] = sizeof(int);
    buffer[15] = sizeof(unsigned int);
    buffer[16] = sizeof(long);
    buffer[17] = sizeof(unsigned long);
    buffer[18] = sizeof(void *);

    #ifdef LDBL_MIN
        buffer[19] = sizeof(long double);
    #endif

    // Complex numbers
    // Too difficult to detect if C99 complex.h is implemented
    buffer[20] = 0;
    buffer[21] = 0;
    buffer[22] = 0;

    #if defined(_SIZE_T) || defined(_SIZE_T_) || defined(_SIZE_T_DEFINED) || defined(_SIZE_T_DEFINED_)
        buffer[23] = sizeof(size_t);
    #endif

    #if defined(_PTRDIFF_T) || defined(_PTRDIFF_T_) || defined(_PTRDIFF_T_DEFINED) || defined(_PTRDIFF_T_DEFINED_)
        buffer[24] = sizeof(ptrdiff_t);
    #endif

    #if defined(_WCHAR_T) || defined(_WCHAR_T_) || defined(_WCHAR_T_DEFINED) || defined(_WCHAR_T_DEFINED_)
        buffer[25] = sizeof(wchar_t);
    #endif
}

void * callfunc_alloc(size_t size, bool zero) {
    if (zero) {
        return calloc(size, 1);
    } else {
        return malloc(size);
    }
}

void callfunc_free(void * pointer) {
    free(pointer);
}

struct CallfuncLibrary * callfunc_new_library() {
    struct CallfuncLibrary * library =
        (struct CallfuncLibrary *) malloc(sizeof(struct CallfuncLibrary));

    return library;
}

void callfunc_del_library(struct CallfuncLibrary * library) {
    assert(library != NULL);

    callfunc_library_close(library);

    free(library);
}

CallfuncError callfunc_library_open(struct CallfuncLibrary * library,
        const char * name) {
    assert(library != NULL);
    assert(name != NULL);

    #ifdef _WIN32
    library->library = LoadLibrary(name);
    #else
    library->library = dlopen(name, RTLD_LAZY);
    #endif

    if (library->library == NULL) {
        _callfunc_error_message = _callfunc_get_dll_error_message();
        return CALLFUNC_FAILURE;
    } else {
        return CALLFUNC_SUCCESS;
    }
}

void callfunc_library_close(struct CallfuncLibrary * library) {
    assert(library != NULL);

    if (library->library != NULL) {
        #ifdef _WIN32
        FreeLibrary((HMODULE) library->library);
        #else
        dlclose(library->library);
        #endif
    }
}

CallfuncError callfunc_library_get_address(struct CallfuncLibrary * library,
        const char * name, void ** dest_pointer) {
    assert(library != NULL);
    assert(name != NULL);

    #ifdef _WIN32
    void * address = GetProcAddress((HMODULE) library->library, name);
    #else
    void * address = dlsym(library->library, name);
    #endif

    if (address == NULL) {
        _callfunc_error_message = _callfunc_get_dll_error_message();
        return CALLFUNC_FAILURE;
    } else {
        *dest_pointer = address;
        return CALLFUNC_SUCCESS;
    }
}

struct CallfuncFunction * callfunc_new_function(
        struct CallfuncLibrary * library) {
    assert(library != NULL);

    struct CallfuncFunction * function =
        (struct CallfuncFunction *) calloc(sizeof(struct CallfuncFunction), 1);

    if (function != NULL) {
        function->library = library;
    }

    return function;
}

void callfunc_del_function(struct CallfuncFunction * function) {
    assert(function != NULL);

    if (function->cif.arg_types != NULL) {
        free(function->cif.arg_types);
    }

    free(function);
}

CallfuncError callfunc_function_define(
        struct CallfuncFunction * function, void * target_function,
        int abi, uint8_t * definition) {
    assert(function != NULL);
    assert(definition != NULL);

    function->function = (void(*)(void)) target_function;

    int32_t num_params;
    int32_t num_fixed_params;
    ffi_type ** parameter_types;
    ffi_type * return_type;

    _callfunc_parse_parameter_definition(definition, &num_params,
        &num_fixed_params,
        &parameter_types, &return_type);

    ffi_abi ffi_abi = (enum ffi_abi)
        (abi == CALLFUNC_DEFAULT_ABI ? FFI_DEFAULT_ABI : abi);
    ffi_status status;

    if (num_fixed_params < 0) {
        status = ffi_prep_cif(&function->cif, ffi_abi,
            num_params, return_type, parameter_types);
    } else {
        status = ffi_prep_cif_var(&function->cif, ffi_abi,
            num_fixed_params, num_params, return_type, parameter_types);
    }

    return _check_ffi_status(status);
}

void callfunc_function_call(struct CallfuncFunction * function,
        uint8_t * argument_buffer) {
    assert(function != NULL);
    assert(argument_buffer != NULL);
    assert(function->function != NULL);
    assert(sizeof(ffi_arg) <= 8);

    int32_t num_args = _callfunc_array_get_int(argument_buffer, 0);
    ffi_arg return_value;
    size_t buffer_index = 4 + CALLFUNC_MAX_RETURN_SIZE;

    void ** arg_pointers = (void **) malloc(num_args * sizeof(void *));
    _CALLFUNC_ABORT_NULL(arg_pointers);

    for (int32_t arg_index = 0; arg_index < num_args; arg_index++) {
        size_t arg_size = argument_buffer[buffer_index];
        buffer_index += 1;

        arg_pointers[arg_index] = &argument_buffer[buffer_index];

        buffer_index += arg_size;
    }

    ffi_call(&function->cif, function->function,
        &return_value, arg_pointers);

    memcpy(&argument_buffer[4], &return_value, sizeof(ffi_arg));
    free(arg_pointers);
}

struct CallfuncStructType * callfunc_new_struct_type() {
    struct CallfuncStructType * struct_type =
        (struct CallfuncStructType *) malloc(sizeof(struct CallfuncStructType));

    if (struct_type != NULL) {
        struct_type->type.size = 0;
        struct_type->type.alignment = 0;
        struct_type->type.type = FFI_TYPE_STRUCT;
    }

    return struct_type;
}

void callfunc_del_struct_type(struct CallfuncStructType * struct_type) {
    assert(struct_type != NULL);

    if (struct_type->type.elements != NULL) {
        free(struct_type->type.elements);
    }

    free(struct_type);
}

CallfuncError callfunc_struct_type_define(
        struct CallfuncStructType * struct_type, uint8_t * definition,
        uint8_t * resultInfo) {
    assert(struct_type != NULL);
    assert(definition != NULL);
    assert(resultInfo != NULL);

    int32_t num_fields;
    ffi_type ** field_types;

    _callfunc_parse_struct_definition(definition, &num_fields, &field_types);

    struct_type->type.elements = field_types;

    size_t * offsets = (size_t *) malloc(num_fields * sizeof(size_t));
    _CALLFUNC_ABORT_NULL(offsets);

    ffi_status status = ffi_get_struct_offsets(FFI_DEFAULT_ABI,
        &(struct_type->type), offsets);

    _callfunc_array_set_int(resultInfo, 0, struct_type->type.size);

    for (int32_t field_index = 0; field_index < num_fields; field_index++) {
        _callfunc_array_set_int(
            resultInfo,
            (1 + field_index) * 4,
            (int32_t) offsets[field_index]);
    }

    free(offsets);

    return _check_ffi_status(status);
}

struct CallfuncCallback * callfunc_new_callback() {
    return (struct CallfuncCallback *)
        calloc(sizeof(struct CallfuncCallback), 1);
}

void callfunc_del_callback(struct CallfuncCallback * callback) {
    assert(callback != NULL);

    if (callback->cif.arg_types != NULL) {
        free(callback->cif.arg_types);
    }

    if (callback->closure != NULL) {
        ffi_closure_free(callback->closure);
    }

    if (callback->definition != NULL) {
        free(callback->definition);
    }

    free(callback);
}

CallfuncError callfunc_callback_define(struct CallfuncCallback * callback,
        uint8_t * definition) {
    assert(callback != NULL);
    assert(definition != NULL);

    int32_t num_params;
    int32_t num_fixed_params;
    ffi_type ** parameter_types;
    ffi_type * return_type;

    _callfunc_parse_parameter_definition(definition, &num_params,
        &num_fixed_params,
        &parameter_types, &return_type);

    assert(num_fixed_params < 0);

    callback->definition = (uint8_t *) malloc(4 + 4 + 1 + num_params);
    _CALLFUNC_ABORT_NULL(callback->definition);
    memcpy(callback->definition, definition, 4 + 4 + 1 + num_params);

    ffi_status status = ffi_prep_cif(&callback->cif, FFI_DEFAULT_ABI,
        num_params, return_type, parameter_types);

    return _check_ffi_status(status);
}

CallfuncError callfunc_callback_bind(struct CallfuncCallback * callback,
        uint8_t * arg_buffer, CallfuncHaxeFunc haxe_function) {
    assert(callback != NULL);
    assert(arg_buffer != NULL);
    #ifndef CALLFUNC_CPP
        assert(haxe_function != NULL);
    #endif

    callback->closure = (ffi_closure *) ffi_closure_alloc(
        sizeof(ffi_closure), &callback->code_location);
    callback->arg_buffer = arg_buffer;
    callback->haxe_function = haxe_function;

    _CALLFUNC_ABORT_NULL(callback->closure);
    _CALLFUNC_ABORT_NULL(callback->code_location);

    ffi_status status = ffi_prep_closure_loc(callback->closure, &callback->cif,
        _callfunc_closure_handler, callback, callback->code_location);

    return _check_ffi_status(status);
}

void * callfunc_callback_get_pointer(struct CallfuncCallback * callback) {
    assert(callback != NULL);
    assert(callback->code_location != NULL);

    return callback->code_location;
}

int64_t callfunc_pointer_to_int64(void * pointer) {
    return (int64_t) pointer;
}

void * callfunc_int64_to_pointer(int64_t address) {
    return (void *) address;
}

void callfunc_pointer_get(void * pointer, uint8_t data_type, uint8_t * buffer,
        int32_t offset) {
    assert(pointer != NULL);
    assert(buffer != NULL);

    size_t data_type_size = _callfunc_data_type_size(data_type);

    assert(data_type_size > 0);

    memcpy(buffer, (char *) pointer + offset, data_type_size);
}

void callfunc_pointer_set(void * pointer, uint8_t data_type, uint8_t * buffer,
        int32_t offset) {
    assert(pointer != NULL);
    assert(buffer != NULL);

    size_t data_type_size = _callfunc_data_type_size(data_type);

    assert(data_type_size > 0);

    memcpy((char *) pointer + offset, buffer, data_type_size);
}

void callfunc_pointer_array_get(void * pointer, uint8_t data_type,
        uint8_t * buffer, int32_t index) {
    assert(pointer != NULL);
    assert(buffer != NULL);

    size_t data_type_size = _callfunc_data_type_size(data_type);

    assert(data_type_size > 0);

    memcpy(buffer, _callfunc_get_aligned_pointer(pointer, data_type, index),
        data_type_size);
}

void callfunc_pointer_array_set(void * pointer, uint8_t data_type,
        uint8_t * buffer, int32_t index) {
    assert(pointer != NULL);
    assert(buffer != NULL);

    size_t data_type_size = _callfunc_data_type_size(data_type);

    assert(data_type_size > 0);

    memcpy(_callfunc_get_aligned_pointer(pointer, data_type, index),
        buffer, data_type_size);
}

size_t _callfunc_data_type_size(uint8_t data_type) {
    switch (data_type) {
        case CALLFUNC_UINT8: return sizeof(uint8_t);
        case CALLFUNC_SINT8: return sizeof(int8_t);
        case CALLFUNC_UINT16: return sizeof(uint16_t);
        case CALLFUNC_SINT16: return sizeof(int16_t);
        case CALLFUNC_UINT32: return sizeof(uint32_t);
        case CALLFUNC_SINT32: return sizeof(int32_t);
        case CALLFUNC_UINT64: return sizeof(uint64_t);
        case CALLFUNC_SINT64: return sizeof(int64_t);
        case CALLFUNC_FLOAT: return sizeof(float);
        case CALLFUNC_DOUBLE: return sizeof(double);
        case CALLFUNC_UCHAR: return sizeof(unsigned char);
        case CALLFUNC_SCHAR: return sizeof(signed char);
        case CALLFUNC_USHORT: return sizeof(unsigned short);
        case CALLFUNC_SSHORT: return sizeof(short);
        case CALLFUNC_SINT: return sizeof(int);
        case CALLFUNC_UINT: return sizeof(unsigned int);
        case CALLFUNC_SLONG: return sizeof(long);
        case CALLFUNC_ULONG: return sizeof(unsigned long);
        case CALLFUNC_POINTER: return sizeof(void *);
        default: assert(0); return 0;
    }
}

const char * _callfunc_get_dll_error_message() {
    #ifdef _WIN32
    static char error_message_buffer[128];

    FormatMessage(
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        GetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &error_message_buffer,
        128,
        NULL
    );
    return error_message_buffer;
    #else
    return dlerror();
    #endif
}

ffi_type * _callfunc_constant_to_ffi_type(int constant) {
    switch (constant) {
        case CALLFUNC_VOID: return &ffi_type_void;
        case CALLFUNC_UINT8: return &ffi_type_uint8;
        case CALLFUNC_SINT8: return &ffi_type_sint8;
        case CALLFUNC_UINT16: return &ffi_type_uint16;
        case CALLFUNC_SINT16: return &ffi_type_sint16;
        case CALLFUNC_UINT32: return &ffi_type_uint32;
        case CALLFUNC_SINT32: return &ffi_type_sint32;
        case CALLFUNC_UINT64: return &ffi_type_uint64;
        case CALLFUNC_SINT64: return &ffi_type_sint64;
        case CALLFUNC_FLOAT: return &ffi_type_float;
        case CALLFUNC_DOUBLE: return &ffi_type_double;
        case CALLFUNC_UCHAR: return &ffi_type_uchar;
        case CALLFUNC_SCHAR: return &ffi_type_schar;
        case CALLFUNC_USHORT: return &ffi_type_ushort;
        case CALLFUNC_SSHORT: return &ffi_type_sshort;
        case CALLFUNC_SINT: return &ffi_type_sint;
        case CALLFUNC_UINT: return &ffi_type_uint;
        case CALLFUNC_SLONG: return &ffi_type_slong;
        case CALLFUNC_ULONG: return &ffi_type_ulong;
        case CALLFUNC_POINTER: return &ffi_type_pointer;
        default: assert(0); return NULL;
    }
}

CallfuncError _check_ffi_status(ffi_status status) {
    switch (status) {
        case FFI_OK:
            return CALLFUNC_SUCCESS;
        case FFI_BAD_TYPEDEF:
            _callfunc_error_message = "FFI_BAD_TYPEDEF";
            return CALLFUNC_FAILURE;
        case FFI_BAD_ABI:
            _callfunc_error_message = "FFI_BAD_ABI";
            return CALLFUNC_FAILURE;
        default:
            _callfunc_error_message = "Unknown FFI error";
            return CALLFUNC_FAILURE;
    }
}

void _callfunc_parse_parameter_definition(uint8_t * definition,
        int32_t * num_params, int32_t * num_fixed_params,
        ffi_type *** parameter_types, ffi_type ** return_type) {

    int32_t num_params_ = _callfunc_array_get_int(definition, 0);
    int32_t num_fixed_params_ = _callfunc_array_get_int(definition, 4);

    *num_params = num_params_;
    *num_fixed_params = num_fixed_params_;
    *parameter_types = (ffi_type **) malloc(sizeof(ffi_type *) * num_params_);
    *return_type = (ffi_type *) _callfunc_constant_to_ffi_type(definition[4 + 4]);

    _CALLFUNC_ABORT_NULL(*parameter_types);

    for (int32_t param_index = 0; param_index < num_params_; param_index++) {
        (*parameter_types)[param_index] =
            _callfunc_constant_to_ffi_type(definition[4 + 4 + 1 + param_index]);
    }
}

void _callfunc_parse_struct_definition(uint8_t * definition,
        int32_t * num_fields, ffi_type *** field_types) {

    int32_t num_fields_ = _callfunc_array_get_int(definition, 0);
    *num_fields = num_fields_;
    *field_types = (ffi_type **) malloc(sizeof(ffi_type *) * (num_fields_ + 1));

    _CALLFUNC_ABORT_NULL(*field_types);

    for (int32_t field_index = 0; field_index < num_fields_; field_index++) {
        (*field_types)[field_index] =
            _callfunc_constant_to_ffi_type(definition[4 + field_index]);
    }

    (*field_types)[num_fields_] = NULL;
}

#define _CALLFUNC_ALIGN_HELPER(ctype) (&((ctype *) pointer)[index])

void * _callfunc_get_aligned_pointer(void * pointer, uint8_t data_type,
        int32_t index) {
    switch (data_type) {
        case CALLFUNC_UINT8: return _CALLFUNC_ALIGN_HELPER(uint8_t);
        case CALLFUNC_SINT8: return _CALLFUNC_ALIGN_HELPER(int8_t);
        case CALLFUNC_UINT16: return _CALLFUNC_ALIGN_HELPER(uint16_t);
        case CALLFUNC_SINT16: return _CALLFUNC_ALIGN_HELPER(int16_t);
        case CALLFUNC_UINT32: return _CALLFUNC_ALIGN_HELPER(uint32_t);
        case CALLFUNC_SINT32: return _CALLFUNC_ALIGN_HELPER(int32_t);
        case CALLFUNC_UINT64: return _CALLFUNC_ALIGN_HELPER(uint64_t);
        case CALLFUNC_SINT64: return _CALLFUNC_ALIGN_HELPER(int64_t);
        case CALLFUNC_FLOAT: return _CALLFUNC_ALIGN_HELPER(float);
        case CALLFUNC_DOUBLE: return _CALLFUNC_ALIGN_HELPER(double);
        case CALLFUNC_UCHAR: return _CALLFUNC_ALIGN_HELPER(unsigned char);
        case CALLFUNC_SCHAR: return _CALLFUNC_ALIGN_HELPER(signed char);
        case CALLFUNC_USHORT: return _CALLFUNC_ALIGN_HELPER(unsigned short);
        case CALLFUNC_SSHORT: return _CALLFUNC_ALIGN_HELPER(short);
        case CALLFUNC_SINT: return _CALLFUNC_ALIGN_HELPER(int);
        case CALLFUNC_UINT: return _CALLFUNC_ALIGN_HELPER(unsigned int);
        case CALLFUNC_SLONG: return _CALLFUNC_ALIGN_HELPER(long);
        case CALLFUNC_ULONG: return _CALLFUNC_ALIGN_HELPER(unsigned long);
        case CALLFUNC_POINTER: return _CALLFUNC_ALIGN_HELPER(void *);
        default: assert(0); return 0;
    }
}
#undef _CALLFUNC_ALIGN_HELPER

void _callfunc_closure_handler(ffi_cif * cif, void * return_value,
        void ** args, void * user_data) {
    assert(user_data != NULL);
    assert(sizeof(ffi_arg) <= 8);

    struct CallfuncCallback * callback = (struct CallfuncCallback *) user_data;

    assert(callback->definition != NULL);
    assert(callback->arg_buffer != NULL);
    #ifndef CALLFUNC_CPP
        assert(callback->haxe_function != NULL);
    #endif

    int32_t num_args = (int32_t) callback->cif.nargs;

    _callfunc_array_set_int(callback->arg_buffer, 0, num_args);

    size_t buffer_index = 4 + CALLFUNC_MAX_RETURN_SIZE;

    for (int32_t arg_index = 0; arg_index < num_args; arg_index++) {
        uint8_t data_type = callback->definition[4 + 4 + 1 + arg_index];
        size_t value_size = _callfunc_data_type_size(data_type);
        void * arg = args[arg_index];

        callback->arg_buffer[buffer_index] = value_size;
        buffer_index += 1;

        memcpy(&callback->arg_buffer[buffer_index], arg, value_size);

        buffer_index += value_size;
    }

    _callfunc_closure_impl(callback);

    uint8_t return_data_type = callback->definition[4 + 4];

    if (return_data_type != CALLFUNC_VOID) {
        memcpy(return_value, &callback->arg_buffer[4], sizeof(ffi_arg));
    }
}

int32_t _callfunc_array_get_int(uint8_t * buffer, size_t offset) {
    return buffer[offset] |
        (buffer[offset + 1] << 8) |
        (buffer[offset + 2] << 16) |
        (buffer[offset + 3] << 24);
}

void _callfunc_array_set_int(uint8_t * buffer, size_t offset, int32_t value) {
    buffer[offset] = value & 0xff;
    buffer[offset + 1] = (value >> 8) & 0xff;
    buffer[offset + 2] = (value >> 16) & 0xff;
    buffer[offset + 3] = (value >> 24) & 0xff;
}

// HXCPP definitions
#if CALLFUNC_CPP
// see callfunc_hxcpp.cpp

// Hashlink exports
#elif CALLFUNC_HL
#include <hl.h>

// It would be nice if I could find in the source code how this structure
// format is generated from the Int64 wrapper. Note that this is not the native
// representation of int64_t.
struct hl_int64 {
    hl_type * type;
    int32_t high;
    int32_t low;
};

vdynamic * hl_callfunc_pointer_to_int64(void * pointer) {
    int64_t result = callfunc_pointer_to_int64(pointer);

    vdynamic * obj = hl_alloc_dynamic(&hlt_dyn);

    struct hl_int64 * wrapper = (struct hl_int64 *) obj;
    wrapper->high = result >> 32;
    wrapper->low = result & 0xffffffff;

    return obj;
}

void * hl_callfunc_int64_to_pointer(vdynamic * obj) {
    struct hl_int64 * wrapper = (struct hl_int64 *) obj;

    uint64_t val = (uint64_t) wrapper->high << 32;
    val |= ((uint64_t) wrapper->low) & 0xffffffffULL;

    return callfunc_int64_to_pointer(val);
}

void _callfunc_closure_impl(struct CallfuncCallback * callback) {
    hl_dyn_call(callback->haxe_function, NULL, 0);
}

#define HL_DEF(name,t,args) DEFINE_PRIM_WITH_NAME(t,name,args,name)
#define HL_DEF2(name,impl_name,t,args) DEFINE_PRIM_WITH_NAME(t,impl_name,args,name)

HL_DEF(callfunc_api_version, _I32, _NO_ARG)
HL_DEF(callfunc_get_error_message, _BYTES, _NO_ARG)
HL_DEF(callfunc_get_sizeof_table, _VOID, _BYTES)
HL_DEF(callfunc_alloc, _ABSTRACT(void*), _I32 _BOOL)
HL_DEF(callfunc_free, _VOID, _ABSTRACT(void*))
HL_DEF(callfunc_new_library, _ABSTRACT(struct CallfuncLibrary), _NO_ARG)
HL_DEF(callfunc_del_library, _VOID, _ABSTRACT(struct CallfuncLibrary))
HL_DEF(callfunc_library_open, _I32, _ABSTRACT(struct CallfuncLibrary) _BYTES)
HL_DEF(callfunc_library_close, _VOID, _ABSTRACT(struct CallfuncLibrary))
HL_DEF(callfunc_library_get_address, _I32, _ABSTRACT(struct CallfuncLibrary) _BYTES _REF(_ABSTRACT(void*)))
HL_DEF(callfunc_new_function, _ABSTRACT(struct CallfuncFunction), _ABSTRACT(struct CallfuncLibrary))
HL_DEF(callfunc_del_function, _VOID, _ABSTRACT(struct CallfuncFunction))
HL_DEF(callfunc_function_define, _I32, _ABSTRACT(struct CallfuncFunction) _ABSTRACT(void*) _I32 _BYTES)
HL_DEF(callfunc_function_call, _VOID, _ABSTRACT(struct CallfuncFunction) _BYTES)
HL_DEF(callfunc_new_struct_type, _ABSTRACT(struct CallfuncStructType), _NO_ARG)
HL_DEF(callfunc_del_struct_type, _VOID, _ABSTRACT(struct CallfuncStructType))
HL_DEF(callfunc_struct_type_define, _I32, _ABSTRACT(struct CallfuncStructType) _BYTES _BYTES)
HL_DEF(callfunc_new_callback, _ABSTRACT(struct CallfuncCallback), _NO_ARG)
HL_DEF(callfunc_del_callback, _VOID, _ABSTRACT(struct CallfuncCallback))
HL_DEF(callfunc_callback_define, _I32, _ABSTRACT(struct CallfuncCallback) _BYTES)
HL_DEF(callfunc_callback_bind, _I32, _ABSTRACT(struct CallfuncCallback) _BYTES _FUN(_VOID, _NO_ARG))
HL_DEF(callfunc_callback_get_pointer, _ABSTRACT(void*), _ABSTRACT(struct CallfuncCallback))
HL_DEF2(callfunc_pointer_to_int64, hl_callfunc_pointer_to_int64, _OBJ(_I32 _I32), _ABSTRACT(void*))
HL_DEF2(callfunc_int64_to_pointer, hl_callfunc_int64_to_pointer, _ABSTRACT(void*), _OBJ(_I32 _I32))
HL_DEF(callfunc_pointer_get, _VOID, _ABSTRACT(void*) _I8 _BYTES _I32)
HL_DEF(callfunc_pointer_set, _VOID, _ABSTRACT(void*) _I8 _BYTES _I32)
HL_DEF(callfunc_pointer_array_get, _VOID, _ABSTRACT(void*) _I8 _BYTES _I32)
HL_DEF(callfunc_pointer_array_set, _VOID, _ABSTRACT(void*) _I8 _BYTES _I32)

#else

void _callfunc_closure_impl(struct CallfuncCallback * callback) {
    assert(0);
    abort();
}

#endif
