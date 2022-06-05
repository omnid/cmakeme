# Test harness for testing the cmake methods created in this project
# Thus, these tests, as executed in this cmake script, will run some sample CMakeLists.txt and examine the outputs

# Configure the test project
execute_process(COMMAND ${CMAKE_COMMAND} -B ${TEST_BIN_DIR} ${TEST_DIR} -DCMAKE_PREFIX_PATH=${PREFIX_PATH})

# Build the test project
execute_process(COMMAND ${CMAKE_COMMAND} --build ${TEST_BIN_DIR})
