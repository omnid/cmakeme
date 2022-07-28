# Test harness for testing the cmake methods created in this project
# Thus, these tests, as executed in this cmake script, will run some sample CMakeLists.txt and examine the outputs

# Clean the test project
message("Clearing Old cmakeme Tests")
execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BIN_DIR} COMMAND_ERROR_IS_FATAL ANY)

# Configure the test project
message("Configuring cmakeme Test Project")
execute_process(COMMAND ${CMAKE_COMMAND} -B ${TEST_BIN_DIR} ${TEST_DIR}
  -DCMAKE_PREFIX_PATH=${CMAKEME_PATH} -DCMAKE_INSTALL_PREFIX=${TEST_BIN_DIR}/install COMMAND_ERROR_IS_FATAL ANY)


# Build and install the test project
message("Building cmakeme Test Project")
execute_process(COMMAND ${CMAKE_COMMAND} --build ${TEST_BIN_DIR} --target install COMMAND_ERROR_IS_FATAL ANY)

if(NOT EXISTS ${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl)
  message(FATAL_ERROR "Could not find ${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl")
endif()

if(NOT EXISTS ${TEST_BIN_DIR}/testpy/testpy.i)
  message(FATAL_ERROR "Could not find ${TEST_BIN_DIR}/testpy/testpy.i")
endif()
