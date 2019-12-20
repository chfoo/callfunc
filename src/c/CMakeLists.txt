cmake_minimum_required(VERSION 3.13)
project(callfunc)

set(LIBFFI_INCLUDE_PATH "" CACHE PATH "Include directory for libffi (ffi.h)")
set(LIBFFI_LIB_PATH "" CACHE FILEPATH "Filename of libffi shared library (libffi.{so,dll,dylib})")
set(HL_INCLUDE_PATH "" CACHE PATH "Include directory for HashLink (hl.h)")
set(HL_LIB_PATH "" CACHE FILEPATH "Filename HashLink shared library (libhl.{so,dll,dylib})")

add_library(callfunc_hdll SHARED callfunc.c)

if(NOT LIBFFI_INCLUDE_PATH)
    find_path(LIBFFI_INCLUDE_PATH_AUTO ffi.h)
endif()

if(NOT HL_INCLUDE_PATH)
    find_path(LIBFFI_INCLUDE_PATH_AUTO hl.h)
endif()

target_include_directories(callfunc_hdll PRIVATE "${LIBFFI_INCLUDE_PATH}" "${LIBFFI_INCLUDE_PATH_AUTO}")
target_include_directories(callfunc_hdll PRIVATE "${HL_INCLUDE_PATH}" "${LIBFFI_INCLUDE_PATH_AUTO}")

if(NOT LIBFFI_LIB_PATH)
    if(NOT WIN32)
        find_library(LIBFFI_LIB_PATH_AUTO ffi)
    else()
        find_library(LIBFFI_LIB_PATH_AUTO libffi)
    endif()
endif()

target_link_libraries(callfunc_hdll PRIVATE "${LIBFFI_LIB_PATH}" "${LIBFFI_LIB_PATH_AUTO}")

if(NOT HL_LIB_PATH)
    if(NOT WIN32)
        find_library(HL_LIB_PATH_AUTO hl)
    else()
        find_library(HL_LIB_PATH_AUTO libhl)
    endif()
endif()

target_link_libraries(callfunc_hdll PRIVATE "${HL_LIB_PATH}" "${HL_LIB_PATH_AUTO}")

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
