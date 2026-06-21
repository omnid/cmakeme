message("githash_test AdditionalTests.cmake: Verifying Installation")
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_exe_hash.h)
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_lib_hash.h)
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_git_hash.h)

execute_process(COMMAND ${TEST_BIN_DIR}/install/bin/githash_test_exe
  OUTPUT_VARIABLE hashes OUTPUT_STRIP_TRAILING_WHITESPACE)

find_package(Git REQUIRED)
message("SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse HEAD OUTPUT_VARIABLE current_git_hash
  WORKING_DIRECTORY ${TEST_DIR} OUTPUT_STRIP_TRAILING_WHITESPACE)

# split the output on newline
string(REPLACE "\n" ";" hash_list ${hashes})
list(GET hash_list 0 GIT_HASH_HEAD)
list(GET hash_list 1 GIT_HASH_GITHASH_TEST_LIB)
list(GET hash_list 2 GIT_HASH_GITHASH_TEST_EXE)

if(NOT (GIT_HASH_HEAD STREQUAL current_git_hash))
  message(FATAL_ERROR "GIT_HASH_HEAD is ${GIT_HASH_HEAD}, expected ${current_git_hash}")
endif()

# Manually hash the files that should go into githash lib
execute_process(COMMAND ${CMAKE_COMMAND} -E cat
  "${TEST_DIR}/include/githash_lib.h"
  "${TEST_BIN_DIR}/cmakeme/include/githash_test/githash_test_git_hash.h"
  "${TEST_DIR}/lib/githash_lib.c"
  "${TEST_DIR}/include/githash_lib.h"
  "${TEST_DIR}/CMakeLists.txt"
  COMMAND ${GIT_EXECUTABLE} hash-object --stdin
  OUTPUT_VARIABLE expected_lib_hash
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT (GIT_HASH_GITHASH_TEST_LIB STREQUAL expected_lib_hash))
    message(FATAL_ERROR "GIT_HASH_GITHASH_TEST_LIB is ${GIT_HASH_GITHASH_TEST_LIB}, expected ${expected_lib_hash}")
endif()

# Manually hash the files that should go into githash exe
execute_process(COMMAND ${CMAKE_COMMAND} -E cat
  "${TEST_DIR}/include/githash_lib.h"
  "${TEST_BIN_DIR}/cmakeme/include/githash_test/githash_test_lib_hash.h"
  "${TEST_BIN_DIR}/cmakeme/include/githash_test/githash_test_git_hash.h"
  "${TEST_BIN_DIR}/libgithash_test_lib.a"
  "${TEST_DIR}/githash_test_exe.c"
  "${TEST_DIR}/CMakeLists.txt"
  COMMAND ${GIT_EXECUTABLE} hash-object --stdin
  OUTPUT_VARIABLE expected_exe_hash
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT (GIT_HASH_GITHASH_TEST_EXE  STREQUAL expected_exe_hash))
    message(FATAL_ERROR "GIT_HASH_GITHASH_TEST_EXE is ${GIT_HASH_GITHASH_TEST_EXE},
 expected ${expected_exe_hash}")
endif()
