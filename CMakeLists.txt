cmake_minimum_required(VERSION 3.0)
project(callfunc)
add_subdirectory(src/c/ out/lib/callfunc/)
add_subdirectory(test/c/examplelib/ out/lib/examplelib/)
