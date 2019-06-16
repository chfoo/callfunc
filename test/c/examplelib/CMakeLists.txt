cmake_minimum_required(VERSION 3.0)
project(callfunc)
add_library(examplelib SHARED examplelib.c)

if(MSVC)
    target_compile_options(examplelib PRIVATE /W4 /WX)
else()
    target_compile_options(examplelib PRIVATE -Wall -Wextra -pedantic -Werror)
endif()

set_target_properties(examplelib PROPERTIES
    PREFIX ""
    C_STANDARD 99
)
