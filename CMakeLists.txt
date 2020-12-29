cmake_minimum_required(VERSION 3.14)
project(cmakeme LANGUAGES NONE VERSION 0.1.0)

include(CMakePackageConfigHelpers)

configure_package_config_file(cmakeme-config.cmake.in cmakeme-config.cmake
  INSTALL_DESTINATION share/cmakeme
  PATH_VARS share/cmakeme
  )

install(FILES
  ${CMAKE_BINARY_DIR}/cmakeme-config.cmake #generated file
  cmakeme_defaults.cmake
  cmakeme_install.cmake
  cmakeme_pack.cmake
  cmakeme_doxygen.cmake
  git_hash.bash.in
  git_hash.cmake
  git_hash_target.bash.in
  DESTINATION share/cmakeme
  )

install(DIRECTORY cpack DESTINATION share/cmakeme)

enable_testing()
add_test(NAME null_test COMMAND echo "TODO: No unit tests exist for tivacmake")
