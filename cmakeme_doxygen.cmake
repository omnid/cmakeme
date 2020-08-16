# Build doxygen
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
  message(WARNING "Doxygen not found, skipping documentation")
  return()
endif()

function(cmakeme_doxygen)
  configure_file(Doxyfile.in Doxyfile)

  add_custom_target(doxygen ALL
    COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Generating Doxygen Documentation"
    VERBATIM)
endfunction()

