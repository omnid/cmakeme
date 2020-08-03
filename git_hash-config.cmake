find_package(Git REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash.bash.in git_hash.bash @ONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash_target.bash.in git_hash_target.bash @ONLY)

function(git_hash)
   # Whenever make all (the default target) is built, update git_hash.h
   add_custom_target(git_hash ALL
                  COMMAND ${CMAKE_BINARY_DIR}/git_hash.bash ${CMAKE_BINARY_DIR}/git_hash.h
                  COMMENT "Updating git_hash.h"
                  BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/git_hash.h
                  VERBATIM
                 )
endfunction()

function(git_hash_target target)
  get_target_property(githash_libs ${target} LINK_LIBRARIES)
  get_target_property(githash_sources ${target} SOURCES)
  get_target_property(githash_includes ${target} INCLUDE_DIRECTORIES)
  get_target_property(githash_srcdir ${target} SOURCE_DIR)
  # append each library location to the list of files to hash
  foreach(githash_lib ${githash_libs})
    list(APPEND files $<TARGET_FILE:${githash_lib}>) 
  endforeach()

  # append each source file location to the list of files to hash
  list(APPEND files ${githash_sources})

  add_custom_target(git_hash_${target}
    COMMAND ${CMAKE_BINARY_DIR}/git_hash_target.bash ${target} ${CMAKE_BINARY_DIR}/${target}_hash.h ${githash_files} ${githash_includes} ${githash_srcdir}/CMakeLists.txt
    COMMENT "Updating ${target}_hash.h"
    BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/${target}_hash.h
    VERBATIM
    )
  add_dependencies(${target} git_hash_${target})
endfunction()
