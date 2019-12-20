cmake_minimum_required(VERSION 3.13)
project(callfunc)

set(LIBFFI_INCLUDE_PATH "" CACHE PATH "Include directory for libffi (ffi.h)")
set(LIBFFI_LIB_PATH "" CACHE FILEPATH "Filename of libffi shared library (libffi.{so,dll,dylib})")
set(HL_INCLUDE_PATH "" CACHE PATH "Include directory for HashLink (hl.h)")
set(HL_LIB_PATH "" CACHE FILEPATH "Filename HashLink shared library (libhl.{so,dll,dylib})")

add_library(callfunc_hdll SHARED callfunc.c)

if(LIBFFI_INCLUDE_PATH)
    target_include_directories(callfunc_hdll PRIVATE "${LIBFFI_INCLUDE_PATH}")
endif()

if(HL_INCLUDE_PATH)
    target_include_directories(callfunc_hdll PRIVATE "${HL_INCLUDE_PATH}")
endif()

if(LIBFFI_LIB_PATH)
    target_link_libraries(callfunc_hdll PRIVATE "${LIBFFI_LIB_PATH}")
else()
    if(NOT WIN32)
        target_link_libraries(callfunc_hdll PRIVATE ffi)
    else()
        target_link_libraries(callfunc_hdll PRIVATE libffi)
    endif()
endif()

if(HL_LIB_PATH)
    target_link_libraries(callfunc_hdll PRIVATE "${HL_LIB_PATH}")
else()
    if(NOT WIN32)
        target_link_libraries(callfunc_hdll PRIVATE hl)
    else()
        target_link_libraries(callfunc_hdll PRIVATE libhl)
    endif()
endif()

if(NOT WIN32)
    target_link_libraries(callfunc_hdll PRIVATE dl)
endif()

if(MSVC)
    target_compile_options(callfunc_hdll PRIVATE /W4)
else()
    target_compile_options(callfunc_hdll PRIVATE -Wall -Wextra -pedantic)
endif()

set_target_properties(callfunc_hdll PROPERTIES
    PREFIX ""
    OUTPUT_NAME "callfunc"
    SUFFIX ".hdll"
    C_STANDARD 99
)
target_compile_definitions(callfunc_hdll PRIVATE CALLFUNC_HL)
