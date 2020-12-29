# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

# create sphinx documentation for the cmake files
# CMAKEME_DOC_DIR - documentation for sphinx.  
# Outputs the resulting documentation to build/html/cmake
function(cmakeme_sphinx_cmake CMAKEME_DOC_DIR)
    find_program(SPHINX_EXECUTABLE
        NAMES sphinx-build
        DOC "Sphinx Documentation Builder (sphinx-doc.org)"
        )

    if(NOT SPHINX_EXECUTABLE)
        message(FATAL_ERROR "SPHINX_EXECUTABLE (sphinx-build) is not found!")
    endif()
    configure_file(${CMAKEME_ROOT_DIR}/sphinx/conf.py.in sphinx/conf.py)

    add_custom_command(OUTPUT html
        COMMAND ${SPHINX_EXECUTABLE}
        -b html
        -c ${CMAKE_BINARY_DIR}/sphinx
        ${CMAKEME_DOC_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}/html/cmake
        > build-html.log
        COMMENT "sphinx-build html: see build-html.log"
        VERBATIM
        )
  set_property(SOURCE html  PROPERTY SYMBOLIC 1) # html is not a real file
  add_custom_target(cmake_docs ALL DEPENDS html)
endfunction()
