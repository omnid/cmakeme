find_package(Git REQUIRED)

function(git_hash)
configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash.bash.in git_hash.bash)
   # Whenever make all (the default target) is built, update git_hash.h
add_custom_target(git_hash ALL
                  COMMAND ${CMAKE_BINARY_DIR}/git_hash.bash ${CMAKE_BINARY_DIR}/git_hash.h
                  COMMENT "Updating git_hash.h"
                  BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/git_hash.h
                  VERBATIM
                 )
endfunction()

