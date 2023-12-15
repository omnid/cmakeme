cmake_minimum_required(VERSION 3.14)
project(cmakeme_tests)

find_package(cmakeme)
cmakeme_defaults(Debug)
cmakeme_python(${CMAKE_CURRENT_LIST_DIR}/cmakeme_python_test cmakeme_python_test)

add_library(testpy testpy.c)
target_include_directories(testpy PUBLIC include/)
cmakeme_swig_python(LIBRARY testpy HEADERS testpy/testpy.h)

