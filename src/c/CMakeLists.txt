cmake_minimum_required(VERSION 3.0)
project(callfunc)

add_library(callfunc_hdll SHARED callfunc.c)
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
