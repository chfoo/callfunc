cmake_minimum_required(VERSION 3.13)
project(callfunc)

set(LIBFFI_INCLUDE_PATH "${CMAKE_HOME_DIRECTORY}/out/libffi/destdir/include" CACHE PATH "Include directory for libffi (ffi.h)")
set(LIBFFI_LIB_PATH "${CMAKE_HOME_DIRECTORY}/out/libffi/destdir/lib/" CACHE PATH "Link directory for libffi (libffi.{so,dll,dynlib})")

add_library(callfunc_hdll SHARED callfunc.c)
target_include_directories(callfunc_hdll BEFORE PRIVATE "${LIBFFI_INCLUDE_PATH}")
target_link_directories(callfunc_hdll BEFORE PRIVATE "${LIBFFI_LIB_PATH}")
target_link_libraries(callfunc_hdll dl ffi)

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
target_compile_definitions(callfunc_hdll PRIVATE LIBHL_EXPORTS)
