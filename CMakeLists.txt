cmake_minimum_required(VERSION 3.22)
project(cmakeme LANGUAGES NONE VERSION 0.2.0)

# Since cmakeme is not installed, we load the individual modules manually
include(${CMAKE_CURRENT_SOURCE_DIR}/cmakeme_defaults.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/sphinx/cmakeme_sphinx.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmakeme_pack.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmakeme_install.cmake)
cmakeme_installdirs()

cmakeme_defaults(Release)

include(CMakePackageConfigHelpers)

set(INSTALL_DIR share/cmakeme)
configure_package_config_file(cmakeme-config.cmake.in cmakeme-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmakeme
  PATH_VARS INSTALL_DIR
  )

set(CMAKEME_ROOT_DIR ${CMAKE_SOURCE_DIR})

cmakeme_sphinx_cmake(${CMAKE_SOURCE_DIR}/doc Omnid ../../omnid/cxx/index.html "2022 by Matthew Elwin")

install(FILES
  ${CMAKE_BINARY_DIR}/cmakeme-config.cmake #generated file
  cmakeme_defaults.cmake
  cmakeme_doxygen.cmake
  cmakeme_install.cmake
  cmakeme_pack.cmake
  cmakeme_python.cmake
  cmakeme_swig.cmake
  git_hash.bash.in
  git_hash.cmake
  git_hash_target.bash.in
  sphinx/cmakeme_sphinx.cmake
  DESTINATION share/cmakeme
  )

install(DIRECTORY cpack DESTINATION share/cmakeme)
install(DIRECTORY sphinx DESTINATION share/cmakeme)

cmakeme_package(EMAIL elwin@northwestern.edu ARCH_ANY)


include(CTest)

if(BUILD_TESTING)
  find_package(Python REQUIRED COMPONENTS Interpreter)

  # This test requires that cmakeme has already been installed
  add_test(NAME cmakeme_test COMMAND
    ${CMAKE_COMMAND}
    -DTEST_BIN_DIR=${CMAKE_BINARY_DIR}/tests
    -DTEST_DIR=${CMAKE_CURRENT_LIST_DIR}/tests
    -DCMAKEME_PATH=${CMAKE_INSTALL_PREFIX}/${INSTALL_DIR}
    -DPYTHON_EXE=${Python_EXECUTABLE}
    -DPYTHON_SITE_DIR=install/lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}/site-packages
    -P ${CMAKE_CURRENT_LIST_DIR}/tests/run_tests.cmake
    )
endif()

# Create a doxygen target so it works with our ROS documentation system
add_custom_target(doxygen COMMAND echo "No doxygen documentation for this package")
