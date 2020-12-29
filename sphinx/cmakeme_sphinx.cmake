# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
cmakeme_sphinx
--------------

    Generate sphinx documentation for .cmake files.
    This module is based off of the system the CMake project uses for
    generating its own documentation in CMake's ``Utilties/Sphinx`` directory
    but can be customized/used by any cmake project.

    Use this module with ``find_package(cmakeme)``
    
#]=======================================================================]

#[=======================================================================[.rst:
Commands
^^^^^^^^
    .. command:: cmakeme_sphinx_cmake

    Generate Sphinx documentation from the CMake Source files.  

        .. code-block:: cmake

            cmakeme_defaults(doc_dir orgname org_url copyright)

        ``doc_dir``
            Directory containing the ``.rst`` files.  These files can
            include a CMake module by using the directive:
            
            ``.. cmake-module:: path_to_cmake_file``

            within a ``.rst`` file.

        ``orgname``
            The organization name, which is shown in the top-left corner of
            all documentation.

        ``org_url``
            The url of the organization's website.

        ``copyright``
            The name of the copyright holder.

    The resulting documentation can be found in ``${CMAKE_SOURCE_DIR}/build/html/cmake``

#]=======================================================================]
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
