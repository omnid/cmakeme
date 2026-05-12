# Test harness for testing the cmake methods created in this project
# Thus, these tests, as executed in this cmake script, will run some sample CMakeLists.txt and examine the outputs
# Items from the envrionmnet should be found in the CMakeLists.txt where the test is defined and passed to this script
# as variables

# This file takes in two variables:
# TEST_BIN_DIR - This is the binary directory where tests will be output
# TEST_DIR - This is the test source code directory

# The test source code directory should have a file called AdditionalTests.cmake
# That file can use the verify_file_exists function (defined here) to verify the installation (it also has access to TEST_BIN_DIR and TEST_DIR)

# Thus, this file, when run as a cmake script, builds a project (during test time) externally, and then allows extra cmake code to be run

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
  -Dcmakeme_DIR=${cmakeme_DIR} -DCMAKE_INSTALL_PREFIX=${TEST_BIN_DIR}/install
  -DBUILD_DOCS=ON COMMAND_ERROR_IS_FATAL ANY)


# Build and install the test project
message("Building and installing cmakeme Test Project")
execute_process(COMMAND ${CMAKE_COMMAND} --build ${TEST_BIN_DIR} --target install COMMAND_ERROR_IS_FATAL ANY)

# Run any additional tests
message("Running Additional Tests")
include(${TEST_DIR}/AdditionalTests.cmake)

