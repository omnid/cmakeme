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
This function also creates a cmake package to import the documentation. It can be found with ``find_package(${PROJECT_NAME}_doxygen)``

.. code-block:: cmake
    
    cmakeme_doxygen(filesOrDirs...)

``filesOrDirs``
The files and directories to search for files to parse with doxygen.

.. note::
    This package uses the built-in doxygen_add_docs  https://cmake.org/cmake/help/latest/module/FindDoxygen.html
    under the hood, but changes some default settings and add an installation target. You can
    override any doxygen settings using the method specified therein. It also installs the documentation
    that is generated.


Results Variables
~~~~~~~~~~~~~~~~~

When calling ``find_package(${PROJECT_NAME}_doxygen)`` The following variables will be defined

.. variable:: ${PROJECT_NAME}_DOXYGEN_FOUND
    This variable is defined if the package was found

.. variable:: ${PROJECT_NAME}_DOXYGEN_DIR
    The directory where the Doxygen html documentation can be found

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

        include(CMakePackageConfigHelpers)
        # Write the configuration file that can be used to find the documentation
        file(WRITE ${CMAKE_BINARY_DIR}/${PROJECT_NAME}_doxygen-config.cmake.in
            "@PACKAGE_INIT@\n
            set(${PROJECT_NAME}_DOXYGEN_DIR  ${PACKAGE_CMAKE_INSTALL_DOCDIR})\n")
            
         configure_package_config_file(${CMAKE_BINARY_DIR}/${PROJECT_NAME}_doxygen-config.cmake.in
             ${PROJECT_NAME}_doxygen-config.cmake
             INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}_doxygen PATH_VARS)

         install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}_doxygen-config.cmake DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}_doxygen)
    endif()

endfunction()

