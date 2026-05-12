message("testpy AdditionalTests.cmake: Verifying Installation")
verify_file_exists(${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl)
verify_file_exists(${TEST_BIN_DIR}/testpy/testpy.i)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/cmakeme_python_test/cmakeme_test.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/cmakeme_python_test/__init__.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/__init__.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/testpy.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/_testpy_swig.so)

message("testpy AdditionalTests.cmake: Beginning the test of the library")
# Run some unit tests that use the installed swig bindings
# Run the tests in a virtual environment to make sure system-installed version is not used
execute_process(COMMAND ${PYTHON_EXE} -m venv ${TEST_BIN_DIR}/install)
# Execute script in the venv by using that venv's python
execute_process(COMMAND ${TEST_BIN_DIR}/install/bin/python ${TEST_DIR}/testpy_unittest.py COMMAND_ERROR_IS_FATAL ANY)
