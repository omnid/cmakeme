# Test harness for testing the cmake methods created in this project
# Thus, these tests, as executed in this cmake script, will run some sample CMakeLists.txt and examine the outputs

# Configure the test project
execute_process(COMMAND ${CMAKE_COMMAND} -B ${TEST_BIN_DIR} ${TEST_DIR} -DCMAKE_PREFIX_PATH=${CMAKEME_PATH} -DCMAKE_INSTALL_PREFIX=${TEST_BIN_DIR}/install)
# Build and install the test project
execute_process(COMMAND ${CMAKE_COMMAND} --build ${TEST_BIN_DIR} --target install)

if(NOT EXISTS ${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl)
  message(FATAL_ERROR "Could not find ${TEST_BIN_DIR}/dist/cmakeme_python_test-0.0.1-py3-none-any.whl")
endif()
