# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

function(cmakeme_sphinx_cmake CMAKEME_DOC_DIR)
    find_program(SPHINX_EXECUTABLE
        NAMES sphinx-build
        DOC "Sphinx Documentation Builder (sphinx-doc.org)"
        )

    if(NOT SPHINX_EXECUTABLE)
        message(FATAL_ERROR "SPHINX_EXECUTABLE (sphinx-build) is not found!")
    endif()

    configure_file(conf.py.in conf.py @ONLY)


    add_custom_command(
        OUTPUT html
        COMMAND ${SPHINX_EXECUTABLE}
        -b html
        -c 
        ${CMAKEME_DOC_DIR} 
        ${CMAKE_CURRENT_BINARY_DIR}/html
        > build-html.log
        COMMENT "sphinx-build html: see build-html.log"
        VERBATIM
        )
endfunction()
