cmake_minimum_required(VERSION 3.14)
project(cmakeme_tests)

find_package(cmakeme)
cmakeme_defaults(Debug)
cmakeme_python(cmakeme_python_test cmakeme_python_test)
