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
        library->library = NULL;
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
        _callfunc_rescursive_free_types(function->cif.arg_types,
            function->cif.nargs);
        function->cif.arg_types = NULL;
    }

    free(function->arg_pointers);
    free(function->arg_pointer_allocated);
    free(function);
}

CallfuncError callfunc_function_define(
        struct CallfuncFunction * function, void * target_function,
        int abi, uint8_t * definition) {
    assert(function != NULL);
    assert(definition != NULL);

    function->function = (void(*)(void)) target_function;

    size_t num_params;
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

    function->arg_pointers = (void **) malloc(num_params * sizeof(void *));
    function->arg_pointer_allocated = (bool *) malloc(num_params * sizeof(bool));
    _CALLFUNC_ABORT_NULL(function->arg_pointers);
    _CALLFUNC_ABORT_NULL(function->arg_pointer_allocated);

    return _check_ffi_status(status);
}

void callfunc_function_call(struct CallfuncFunction * function,
        uint8_t * argument_buffer) {
    assert(function != NULL);
    assert(argument_buffer != NULL);
    assert(function->function != NULL);
    assert(sizeof(ffi_arg) <= 8);

    unsigned int num_args = function->cif.nargs;
    ffi_arg return_value;
    size_t buffer_index = 0;
    size_t buffer_length = _callfunc_array_get_int(argument_buffer, buffer_index);
    buffer_index += 4;
    buffer_index += CALLFUNC_MAX_RETURN_SIZE;

    for (size_t index = 0; index < num_args; index++) {
        assert(buffer_index < buffer_length);
        ffi_type * arg_type = function->cif.arg_types[index];
        size_t arg_size;

        if (arg_type->type == FFI_TYPE_STRUCT) {
            void * copied_struct = _callfunc_get_buffer_struct_copy(
                    argument_buffer, buffer_index, arg_type->size);

            arg_size = sizeof(void *);
            function->arg_pointers[index] = copied_struct;
            function->arg_pointer_allocated[index] = true;
        } else {
            arg_size = arg_type->size;
            function->arg_pointers[index] = &argument_buffer[buffer_index];
            function->arg_pointer_allocated[index] = false;
        }

        buffer_index += arg_size;
    }

    assert(buffer_index == buffer_length);

    if (function->cif.rtype->type == FFI_TYPE_STRUCT) {
        // API user is responsible for freeing this buffer
        void * return_buffer = malloc(function->cif.rtype->size);

        ffi_call(&function->cif, function->function,
            return_buffer, function->arg_pointers);

        memcpy(&argument_buffer[4], &return_buffer, sizeof(void *));
    } else {
        ffi_call(&function->cif, function->function,
            &return_value, function->arg_pointers);

        memcpy(&argument_buffer[4], &return_value, sizeof(ffi_arg));
    }

    for (size_t index = 0; index < num_args; index++) {
        if (function->arg_pointer_allocated[index]) {
            free(function->arg_pointers[index]);
        }
    }
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
        _callfunc_rescursive_free_types(struct_type->type.elements, SIZE_MAX);
        struct_type->type.elements = NULL;
    }

    free(struct_type);
}

CallfuncError callfunc_struct_type_define(
        struct CallfuncStructType * struct_type, uint8_t * definition,
        uint8_t * resultInfo) {
    assert(struct_type != NULL);
    assert(definition != NULL);
    assert(resultInfo != NULL);

    size_t num_fields;
    ffi_type ** field_types;

    _callfunc_parse_struct_definition(definition, &num_fields, &field_types);

    struct_type->type.elements = field_types;

    size_t * offsets = (size_t *) malloc(num_fields * sizeof(size_t));
    _CALLFUNC_ABORT_NULL(offsets);

    ffi_status status = ffi_get_struct_offsets(FFI_DEFAULT_ABI,
        &(struct_type->type), offsets);

    _callfunc_array_set_int(resultInfo, 0, struct_type->type.size);

    for (size_t field_index = 0; field_index < num_fields; field_index++) {
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
        _callfunc_rescursive_free_types(callback->cif.arg_types,
            callback->cif.nargs);
        callback->cif.arg_types = NULL;
    }

    if (callback->closure != NULL) {
        ffi_closure_free(callback->closure);
        callback->closure = NULL;
    }

    free(callback);
}

CallfuncError callfunc_callback_define(struct CallfuncCallback * callback,
        uint8_t * definition) {
    assert(callback != NULL);
    assert(definition != NULL);

    size_t num_params;
    int32_t num_fixed_params;
    ffi_type ** parameter_types;
    ffi_type * return_type;

    _callfunc_parse_parameter_definition(definition, &num_params,
        &num_fixed_params,
        &parameter_types, &return_type);

    assert(num_fixed_params < 0);

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
        size_t * num_params, int32_t * num_fixed_params,
        ffi_type *** parameter_types, ffi_type ** return_type) {
    assert(definition != NULL);
    assert(num_params != NULL);
    assert(num_fixed_params != NULL);
    assert(parameter_types != NULL);
    assert(return_type != NULL);

    size_t offset = 0;
    size_t buffer_length = _callfunc_array_get_int(definition, offset);
    offset += 4;
    *num_params = _callfunc_array_get_int(definition, offset);
    offset += 4;
    *num_fixed_params = _callfunc_array_get_int(definition, offset);
    offset += 4;

    *parameter_types = (ffi_type **) malloc(sizeof(ffi_type *) * *num_params);

    size_t bytes_read_child;
    *return_type = _callfunc_parse_type(definition, offset, &bytes_read_child);
    offset += bytes_read_child;

    _CALLFUNC_ABORT_NULL(*parameter_types);

    for (size_t index = 0; index < *num_params; index++) {
        assert(offset < buffer_length);
        size_t bytes_read_child;

        (*parameter_types)[index] =
            _callfunc_parse_type(definition, offset, &bytes_read_child);

        offset += bytes_read_child;
    }

    assert(offset == buffer_length);
}

void _callfunc_parse_struct_definition(uint8_t * definition,
        size_t * num_fields, ffi_type *** field_types) {
    assert(definition != NULL);
    assert(num_fields != NULL);
    assert(field_types != NULL);

    size_t offset = 0;
    size_t buffer_length = _callfunc_array_get_int(definition, offset);
    offset += 4;

    *num_fields = _callfunc_array_get_int(definition, offset);
    *field_types = (ffi_type **) malloc(sizeof(ffi_type *) * (*num_fields + 1));
    _CALLFUNC_ABORT_NULL(*field_types);
    offset += 4;

    for (size_t index = 0; index < *num_fields; index++) {
        assert(offset < buffer_length);
        size_t bytes_read_child;

        (*field_types)[index] =
            _callfunc_parse_type(definition, offset, &bytes_read_child);

        offset += bytes_read_child;
    }

    (*field_types)[*num_fields] = NULL;
    assert(offset == buffer_length);
}

ffi_type * _callfunc_parse_type(uint8_t * buffer, size_t offset,
        size_t * bytes_read) {
    assert(buffer != NULL);
    assert(bytes_read != NULL);

    size_t bytes_read_local = 0;
    int type_constant = buffer[offset];
    bytes_read_local += 1;
    offset += 1;

    if (type_constant == CALLFUNC_STRUCT) {
        ffi_type * type = (ffi_type *) malloc(sizeof(ffi_type));

        _CALLFUNC_ABORT_NULL(type);

        type->type = FFI_TYPE_STRUCT;
        type->size = 0;
        type->alignment = 0;

        size_t num_fields = _callfunc_array_get_int(buffer, offset);
        type->elements = (ffi_type **) malloc(sizeof(ffi_type *) * (num_fields + 1));

        _CALLFUNC_ABORT_NULL(type->elements);

        bytes_read_local += 4;
        offset += 4;

        for (size_t index = 0; index < num_fields; index++) {
            size_t bytes_read_child;

            type->elements[index] =
                _callfunc_parse_type(buffer, offset, &bytes_read_child);

            bytes_read_local += bytes_read_child;
            offset += bytes_read_child;
        }

        type->elements[num_fields] = NULL;

        *bytes_read = bytes_read_local;
        return type;

    } else {
        *bytes_read = bytes_read_local;
        return _callfunc_constant_to_ffi_type(type_constant);
    }
}

void * _callfunc_get_buffer_struct_copy(uint8_t * buffer, size_t offset,
        size_t struct_size) {
    void * original_struct;
    memcpy(&original_struct, &buffer[offset], sizeof(void *));
    void * copied_struct = malloc(struct_size);

    _CALLFUNC_ABORT_NULL(copied_struct);

    memcpy(copied_struct, original_struct, struct_size);

    return copied_struct;
}

void _callfunc_rescursive_free_types(ffi_type ** types, size_t length) {
    for (size_t index = 0; index < length; index++) {
        ffi_type * type = types[index];

        if (type == NULL) {
            break;
        } else if (type->type != FFI_TYPE_STRUCT) {
            continue;
        }

        if (type->elements != NULL) {
            _callfunc_rescursive_free_types(type->elements, SIZE_MAX);
        }

        free(type);
    }

    free(types);
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

    assert(callback->arg_buffer != NULL);
    #ifndef CALLFUNC_CPP
        assert(callback->haxe_function != NULL);
    #endif

    int32_t num_args = (int32_t) callback->cif.nargs;
    size_t buffer_index = 0;
    size_t buffer_size = _callfunc_array_get_int(callback->arg_buffer, buffer_index);
    buffer_index += 4;

    buffer_index += CALLFUNC_MAX_RETURN_SIZE;

    for (int32_t index = 0; index < num_args; index++) {
        assert(buffer_index < buffer_size);
        size_t value_size;
        ffi_type * arg_type = callback->cif.arg_types[index];

        if (arg_type->type == FFI_TYPE_STRUCT) {
            value_size = sizeof(void *);
        } else {
            value_size = arg_type->size;
        }

        void * arg = args[index];

        memcpy(&callback->arg_buffer[buffer_index], arg, value_size);

        buffer_index += value_size;
    }

    _callfunc_closure_impl(callback);

    if (callback->cif.rtype->type != FFI_TYPE_VOID) {
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

typedef struct CallfuncLibrary _hl_CallfuncLibrary;
typedef struct CallfuncFunction _hl_CallfuncFunction;
typedef struct CallfuncStructType _hl_CallfuncStructType;
typedef struct CallfuncCallback _hl_CallfuncCallback;
typedef void* _hl_CallfuncVoidStar;

// It would be nice if I could find in the source code how this structure
// format is generated from the Int64 wrapper. Note that this is not the native
// representation of int64_t.
struct hl_int64 {
    hl_type * type;
    int32_t high;
    int32_t low;
};

CALLFUNC_API
vdynamic * callfunc_pointer_to_int64_hl(void * pointer) {
    int64_t result = callfunc_pointer_to_int64(pointer);

    vdynamic * obj = hl_alloc_dynamic(&hlt_dyn);

    struct hl_int64 * wrapper = (struct hl_int64 *) obj;
    wrapper->high = result >> 32;
    wrapper->low = result & 0xffffffff;

    return obj;
}

CALLFUNC_API
void * callfunc_int64_to_pointer_hl(vdynamic * obj) {
    struct hl_int64 * wrapper = (struct hl_int64 *) obj;

    uint64_t val = (uint64_t) wrapper->high << 32;
    val |= ((uint64_t) wrapper->low) & 0xffffffffULL;

    return callfunc_int64_to_pointer(val);
}

void _callfunc_closure_impl(struct CallfuncCallback * callback) {
    hl_dyn_call(callback->haxe_function, NULL, 0);
}

#define HL_DEF(name,t,args) DEFINE_PRIM_WITH_NAME(t,callfunc_##name,args,name)
#define HL_DEF2(name,impl_name,t,args) DEFINE_PRIM_WITH_NAME(t,impl_name,args,name)

HL_DEF(api_version, _I32, _NO_ARG)
HL_DEF(get_error_message, _BYTES, _NO_ARG)
HL_DEF(get_sizeof_table, _VOID, _BYTES)
HL_DEF(alloc, _ABSTRACT(_hl_CallfuncVoidStar), _I32 _BOOL)
HL_DEF(free, _VOID, _ABSTRACT(_hl_CallfuncVoidStar))
HL_DEF(new_library, _ABSTRACT(_hl_CallfuncLibrary), _NO_ARG)
HL_DEF(del_library, _VOID, _ABSTRACT(_hl_CallfuncLibrary))
HL_DEF(library_open, _I32, _ABSTRACT(_hl_CallfuncLibrary) _BYTES)
HL_DEF(library_close, _VOID, _ABSTRACT(_hl_CallfuncLibrary))
HL_DEF(library_get_address, _I32, _ABSTRACT(_hl_CallfuncLibrary) _BYTES _REF(_ABSTRACT(_hl_CallfuncVoidStar)))
HL_DEF(new_function, _ABSTRACT(_hl_CallfuncFunction), _ABSTRACT(_hl_CallfuncLibrary))
HL_DEF(del_function, _VOID, _ABSTRACT(_hl_CallfuncFunction))
HL_DEF(function_define, _I32, _ABSTRACT(_hl_CallfuncFunction) _ABSTRACT(_hl_CallfuncVoidStar) _I32 _BYTES)
HL_DEF(function_call, _VOID, _ABSTRACT(_hl_CallfuncFunction) _BYTES)
HL_DEF(new_struct_type, _ABSTRACT(_hl_CallfuncStructType), _NO_ARG)
HL_DEF(del_struct_type, _VOID, _ABSTRACT(_hl_CallfuncStructType))
HL_DEF(struct_type_define, _I32, _ABSTRACT(_hl_CallfuncStructType) _BYTES _BYTES)
HL_DEF(new_callback, _ABSTRACT(_hl_CallfuncCallback), _NO_ARG)
HL_DEF(del_callback, _VOID, _ABSTRACT(_hl_CallfuncCallback))
HL_DEF(callback_define, _I32, _ABSTRACT(_hl_CallfuncCallback) _BYTES)
HL_DEF(callback_bind, _I32, _ABSTRACT(_hl_CallfuncCallback) _BYTES _FUN(_VOID, _NO_ARG))
HL_DEF(callback_get_pointer, _ABSTRACT(_hl_CallfuncVoidStar), _ABSTRACT(_hl_CallfuncCallback))
HL_DEF(pointer_to_int64_hl, _OBJ(_I32 _I32), _ABSTRACT(_hl_CallfuncVoidStar))
HL_DEF(int64_to_pointer_hl, _ABSTRACT(_hl_CallfuncVoidStar), _OBJ(_I32 _I32))
HL_DEF(pointer_get, _VOID, _ABSTRACT(_hl_CallfuncVoidStar) _I8 _BYTES _I32)
HL_DEF(pointer_set, _VOID, _ABSTRACT(_hl_CallfuncVoidStar) _I8 _BYTES _I32)
HL_DEF(pointer_array_get, _VOID, _ABSTRACT(_hl_CallfuncVoidStar) _I8 _BYTES _I32)
HL_DEF(pointer_array_set, _VOID, _ABSTRACT(_hl_CallfuncVoidStar) _I8 _BYTES _I32)

#else

void _callfunc_closure_impl(struct CallfuncCallback * callback) {
    assert(0);
    abort();
}

#endif
