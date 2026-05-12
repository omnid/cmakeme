message("githash_test AdditionalTests.cmake: Verifying Installation")
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_exe_hash.h)
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_lib_hash.h)
verify_file_exists(${TEST_BIN_DIR}/install/include/githash_test/githash_test_git_hash.h)
