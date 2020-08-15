find_package(Git REQUIRED)

# configure files to temporary directory so they cna be copied and given execute permissions
configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash.bash.in
  ${CMAKE_BINARY_DIR}/tmp/git_hash.bash @ONLY)

configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash_target.bash.in
  ${CMAKE_BINARY_DIR}/tmp/git_hash_target.bash @ONLY)

file(COPY ${CMAKE_BINARY_DIR}/tmp/git_hash.bash  ${CMAKE_BINARY_DIR}/tmp/git_hash_target.bash
  DESTINATION ${CMAKE_BINARY_DIR}
  FILE_PERMISSIONS
  OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
  )

# add the githash target
add_custom_target(git_hash 
  COMMAND ${CMAKE_BINARY_DIR}/git_hash.bash ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/git_hash.h
  COMMENT "Updating git_hash.h"
  BYPRODUCTS ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/git_hash.h
  VERBATIM
  )

# Create target_hash.h which contains hashes of the current git repository and the target's dependencies
function(cmakeme_hash target)
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
    COMMAND ${CMAKE_BINARY_DIR}/git_hash_target.bash ${target} ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${target}_hash.h ${githash_files} ${githash_includes} ${githash_srcdir}/CMakeLists.txt
    COMMENT "Updating ${target}_hash.h"
    BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${target}_hash.h
    VERBATIM
    )
  add_dependencies(git_hash_${target} git_hash)
  add_dependencies(${target} git_hash_${target})
  target_include_directories(${target} PUBLIC $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/cmakeme/include/>)
endfunction()
