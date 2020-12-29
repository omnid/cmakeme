# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

# create sphinx documentation for the cmake files
# CMAKEME_DOC_DIR - documentation for sphinx.  
# Outputs the resulting documentation to build/html/cmake
function(cmakeme_sphinx_cmake doc_dir orgname org_url copyright)
    find_program(SPHINX_EXECUTABLE
        NAMES sphinx-build
        DOC "Sphinx Documentation Builder (sphinx-doc.org)"
        )

    if(NOT SPHINX_EXECUTABLE)
        message(FATAL_ERROR "SPHINX_EXECUTABLE (sphinx-build) is not found!")
    endif()
    set(conf_homepage ${org_url})
    set(conf_organization ${orgname})
    set(conf_copyright ${copyright})
    configure_file(${CMAKEME_ROOT_DIR}/sphinx/conf.py.in sphinx/conf.py)

    add_custom_command(OUTPUT html
        COMMAND ${SPHINX_EXECUTABLE}
        -b html
        -c ${CMAKE_BINARY_DIR}/sphinx
        ${doc_dir}
        ${CMAKE_CURRENT_BINARY_DIR}/html/cmake
        > build-html.log
        COMMENT "sphinx-build html: see build-html.log"
        VERBATIM
        )
  add_custom_target(cmake_docs ALL DEPENDS html)
endfunction()
