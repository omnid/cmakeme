#[=======================================================================[.rst:
cmakeme_doxygen
---------------
Doxygen with a default configuration used by the omnid project

Use this module with ``find_package(cmakeme)``
#]=======================================================================]

#[=======================================================================[.rst:
Commands
^^^^^^^^
.. command:: cmakeme_doxygen

Call ``cmakeme_doxygen()`` to build doxygen documentation using the ``cmakeme`` Doxygen settings.

.. code-block:: cmake
    
    cmakeme_doxygen(display_title)

    ``display_title``
    The title of the project, to be displayed in the Doxygen documentation
#]=======================================================================]
function(cmakeme_doxygen display_title)
    # Build doxygen
    find_package(Doxygen)
    if(NOT DOXYGEN_FOUND)
        message(WARNING "Doxygen not found, skipping documentation")
        return()
    endif()
    set(conf_project_title ${display_title})
    configure_file(${CMAKEME_ROOT_DIR}/Doxyfile.in Doxyfile)

    add_custom_target(doxygen ALL
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating Doxygen Documentation"
        VERBATIM)

    install(DIRECTORY 
endfunction()

