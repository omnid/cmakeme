cmake_minimum_required(VERSION 3.14)
project(githash_test)
find_package(cmakeme)

add_library(githash_test_lib lib/githash_lib.c)
target_include_directories(githash_test_lib PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>)
cmakeme_hash(githash_test_lib)

add_executable(githash_test_exe githash_test_exe.c)
target_link_libraries(githash_test_exe githash_test_lib)
cmakeme_hash(githash_test_exe)

cmakeme_install(TARGETS githash_test_lib githash_test_exe)

