cmake_minimum_required(VERSION 3.0)
project(callfunc)

include (GenerateExportHeader)
add_library(examplelib SHARED examplelib.c)

GENERATE_EXPORT_HEADER( examplelib
    BASE_NAME examplelib
    EXPORT_MACRO_NAME examplelib_EXPORT
    EXPORT_FILE_NAME examplelib_Export.h
    STATIC_DEFINE examplelib_BUILT_AS_STATIC
)

if(MSVC)
    target_compile_options(examplelib PRIVATE /W4 /WX)
else()
    target_compile_options(examplelib PRIVATE -Wall -Wextra -pedantic -Werror)
endif()

set_target_properties(examplelib PROPERTIES
    PREFIX ""
    C_STANDARD 99
)
