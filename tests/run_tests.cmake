# Test harness for testing the cmake methods created in this project
# Thus, these tests, as executed in this cmake script, will run some sample CMakeLists.txt and examine the outputs
# Items from the envrionmnet should be found in the CMakeLists.txt where the test is defined and passed to this script
# as variables

# Ensure that a file exists and error out on an error
function(verify_file_exists file)
  if(NOT EXISTS ${file})
    message(FATAL_ERROR "File ${file} not found")
  endif()
endfunction()

# Clean the test project
message("Clearing Old cmakeme Tests")
execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BIN_DIR} COMMAND_ERROR_IS_FATAL ANY)

# Configure the test project
message("Configuring cmakeme Test Project")
execute_process(COMMAND ${CMAKE_COMMAND} -B ${TEST_BIN_DIR} ${TEST_DIR}
  -DCMAKE_PREFIX_PATH=${CMAKEME_PATH} -DCMAKE_INSTALL_PREFIX=${TEST_BIN_DIR}/install
  -DBUILD_DOCS=ON COMMAND_ERROR_IS_FATAL ANY)


# Build and install the test project
message("Building and installing cmakeme Test Project")
execute_process(COMMAND ${CMAKE_COMMAND} --build ${TEST_BIN_DIR} --target install COMMAND_ERROR_IS_FATAL ANY)

message("Verifying Installation")
verify_file_exists(${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl)
verify_file_exists(${TEST_BIN_DIR}/testpy/testpy.i)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/cmakeme_python_test/cmakeme_test.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/cmakeme_python_test/__init__.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/__init__.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/testpy.py)
verify_file_exists(${TEST_BIN_DIR}/${PYTHON_SITE_DIR}/testpy/_testpy_swig.so)

message("Beginning the test of the library")
# Run some unit tests that use the installed swig bindings
# Run the tests in a virtual environment to make sure system-installed version is not used
execute_process(COMMAND ${PYTHON_EXE} -m venv ${TEST_BIN_DIR}/install)
# Execute script in the venv by using that venv's python
execute_process(COMMAND ${TEST_BIN_DIR}/install/bin/python ${TEST_DIR}/testpy_unittest.py COMMAND_ERROR_IS_FATAL ANY)
