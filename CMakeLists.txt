cmake_minimum_required(VERSION 3.14)
project(git_hash LANGUAGES NONE VERSION 0.1.0)

include(CMakePackageConfigHelpers)
configure_package_config_file(cmakeme-config.cmake.in cmakeme-config.cmake
  INSTALL_DESTINATION share/cmakeme
  )

install(FILES
  ${CMAKE_BINARY_DIR}/cmakeme-config.cmake
  cmakeme_defaults.cmake
  cmakeme_install.cmake
  git_hash.bash.in
  git_hash.cmake
  git_hash_target.bash.in
  DESTINATION share/cmakeme
  )

