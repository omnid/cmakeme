cmake_minimum_required(VERSION 3.14)
project(git_hash LANGUAGES NONE VERSION 0.1.0)

install(FILES git_hash.bash.in git_hash_target.bash.in git_hash-config.cmake
  DESTINATION share/git_hash)

