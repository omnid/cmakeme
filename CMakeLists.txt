cmake_minimum_required(VERSION 3.14)
project(cmakeme LANGUAGES NONE VERSION 0.1.0)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmakeme_defaults.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/sphinx/cmakeme_sphinx.cmake)
cmakeme_defaults(Release)
option(BUILD_SPHINX "Build the Sphinx Documentation" ON)

include(CMakePackageConfigHelpers)

set(INSTALL_DIR share/cmakeme)
configure_package_config_file(cmakeme-config.cmake.in cmakeme-config.cmake
  INSTALL_DESTINATION share/cmakeme
  PATH_VARS INSTALL_DIR
  )

set(CMAKEME_ROOT_DIR ${CMAKE_SOURCE_DIR})

if(BUILD_SPHINX)
    cmakeme_sphinx_cmake(${CMAKE_SOURCE_DIR}/doc Omnid https://omnid.github.io/ "2021 by Matthew Elwin")
endif()

install(FILES
  ${CMAKE_BINARY_DIR}/cmakeme-config.cmake #generated file
  cmakeme_defaults.cmake
  cmakeme_install.cmake
  cmakeme_pack.cmake
  cmakeme_doxygen.cmake
  git_hash.bash.in
  git_hash.cmake
  git_hash_target.bash.in
  sphinx/cmakeme_sphinx.cmake
  Doxyfile.in
  DESTINATION share/cmakeme
  )

install(DIRECTORY cpack DESTINATION share/cmakeme)
install(DIRECTORY sphinx DESTINATION share/cmakeme)

enable_testing()
add_test(NAME null_test COMMAND echo "TODO: No unit tests exist for tivacmake")
