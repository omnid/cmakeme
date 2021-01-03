#[=======================================================================[.rst:
cmakeme_doxygen
---------------
Doxygen with a default configuration used by the omnid project

Use this module with ``find_package(cmakeme)``
#]=======================================================================]

#[=======================================================================[.rst:
Variables
^^^^^^^^^
.. variable:: BUILD_DOXYGEN

Default (``OFF``) set to (``ON``) to build the doxygen documentation when calling ``cmakeme_doxygen``

Commands
^^^^^^^^
.. command:: cmakeme_doxygen

Call ``cmakeme_doxygen()`` to build doxygen documentation using the ``cmakeme`` Doxygen settings.

.. code-block:: cmake
    
    cmakeme_doxygen(filesOrDirs...)

``filesOrDirs``
The files and directories to search for files to parse with doxygen.

This uses the built-in doxygen_add_docs  https://cmake.org/cmake/help/latest/module/FindDoxygen.html
under the hood, but changes some default settings and add an installation target. You can
override any doxygen settings using the method specified therein. It also installs the documentation
that is generated.

#]=======================================================================]
option(BUILD_DOXYGEN "Build the doxygen documentation automatically" OFF)
function(cmakeme_doxygen filesOrDirs)
    if(BUILD_DOXYGEN)
        find_package(Doxygen OPTIONAL_COMPONENTS dot mscgen dia)
        if(NOT DOXYGEN_FOUND)
            message(WARNING "Doxygen not found, skipping documentation")
            return()
        endif()

        if(NOT EXISTS DOXYGEN_USE_MDFILE_AS_MAINPAGE)
            set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
        endif()
      

            doxygen_add_docs(doxygen ${filesOrDirs} ALL)
            install(DIRECTORY ${CMAKE_BINARY_DIR}/html DESTINATION ${CMAKE_INSTALL_DOCDIR})
    endif()

endfunction()

