# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
cmakeme_sphinx
--------------

Generate sphinx documentation for .cmake and .py files.

This module is based off of the system the CMake project uses for
generating its own documentation in CMake's ``Utilties/Sphinx`` directory
but can be customized/used by any cmake project.

It also has facilities for documenting python modules with sphinx.
Docstrings are automatically extracted from the provided modules

This module is included with ``find_package(cmakeme)`` but can also
be found with ``find_package(cmakeme_sphinx)``

#]=======================================================================]

#[=======================================================================[.rst:
Variables
^^^^^^^^^
.. variable:: BUILD_SPHINX_CMAKE

Default (``OFF``). Set to ``ON`` to build sphinx documentation when calling ``cmakeme_sphinx_cmake``

.. variable:: BUILD_DOCS

Default (``OFF``). Set to ``ON`` to build all documentation in the system (sphinx, doxygen, etc)

Commands
^^^^^^^^
.. command:: cmakeme_sphinx_cmake

Generate Sphinx documentation from the CMake Source files.

    .. code-block:: cmake

        cmakeme_sphinx_cmake(doc_dir orgname org_url copyright)

    ``doc_dir``
        Directory containing the ``.rst`` files.  These files can
        include a CMake module by using:

        ``.. cmake-module:: path_to_cmake_file`` within a ``.rst`` file.

    ``orgname``
        The organization name, which is shown in the top-left corner of
        all documentation.

    ``org_url``
        The url of the organization's website.

    ``copyright``
        The name of the copyright holder.

#]=======================================================================]
option(BUILD_SPHINX_CMAKE "Build the CMake Sphinx Documentation" OFF)
function(cmakeme_sphinx_cmake doc_dir orgname org_url copyright)
    if(BUILD_SPHINX_CMAKE OR BUILD_DOCS)
        find_program(SPHINX_EXECUTABLE
            NAMES sphinx-build
            DOC "Sphinx Documentation Builder (sphinx-doc.org)"
            )

        if(NOT SPHINX_EXECUTABLE)
            message(WARNING "SPHINX_EXECUTABLE (sphinx-build) is not found, skipping CMAke documentation")
            return()
        endif()
        set(conf_homepage ${org_url})
        set(conf_organization ${orgname})
        set(conf_copyright ${copyright})
        configure_file(${CMAKEME_ROOT_DIR}/sphinx/conf_cmake.py.in sphinx/conf.py)

        add_custom_target(cmake_docs ALL
            COMMAND ${SPHINX_EXECUTABLE}
            -b html
            -c ${CMAKE_BINARY_DIR}/sphinx
            ${doc_dir}
            ${CMAKE_CURRENT_BINARY_DIR}/html/cmake
            > build-html.log
            COMMENT "sphinx-build html: see build-html.log"
            VERBATIM
            )

        install(DIRECTORY ${CMAKE_BINARY_DIR}/html/cmake/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/cmake)

    endif()
endfunction()

#[=======================================================================[.rst:
.. command:: cmakeme_sphinx_python

Generate Sphinx documentation from python modules

    .. code-block:: cmake

        cmakeme_sphinx_python(PACKAGE pkgname MODULES mod1 [mod2 ...] [DEPENDS dep...])

     ``pkgname``
        The name of the python package that is being documented

     ``mod1``
        The python modules to document, without the .py extension. multiple
        modules may be specified.

     ``dep``
        Documentation depends on anothe target. For example, if this is being
        used to generate documentation for swig bindings, it must depend on
        the swig target being built

#]=======================================================================]

function(cmakeme_sphinx_python)
  # Parse the arguments
  cmake_parse_arguments(
    CMAKEME_SPHINX_PYTHON
    ""
    "PACKAGE"
    "MODULES;DEPENDS"
    ${ARGN}
    )
  if(CMAKEME_SPHINX_PYTHON_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments to cmakeme_install: ${CMAKEME_SPHINX_PYTHON_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT CMAKEME_SPHINX_PYTHON_PACKAGE)
    message(FATAL_ERROR "PACKAGE argument not specified")
  endif()

  if(NOT CMAKEME_SPHINX_PYTHON_MODULES)
    message(FATAL_ERROR "MODULES not specified")
  endif()

  if(BUILD_DOCS)
    set(CMAKEME_SPHINX_PYTHON_MOD_RST "")
    foreach(mod ${CMAKEME_SPHINX_PYTHON_MODULES})
      set(CMAKEME_SPHINX_PYTHON_MOD_RST "${CMAKEME_SPHINX_PYTHON_MOD_RST}\n.. automodule:: ${mod}\n  :members:\n")
    endforeach()

    # Make index.rst. For now, all modules are documented in one gian index.rst file
    # Alternatively we could generate a separate .rst per module and put them together in an index
    configure_file(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/index_python.rst.in ${CMAKE_BINARY_DIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE}/index.rst)

    # The conf.py file contains the settings for sphinx
    configure_file(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/conf_python.py.in ${CMAKE_BINARY_DIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE}/conf.py)

    find_program(SPHINX_EXECUTABLE
      NAMES sphinx-build
      DOC "Sphinx Documentation Builder (sphinx-doc.org)"
      )

    if(NOT SPHINX_EXECUTABLE)
      message(WARNING "SPHINX_EXECUTABLE (sphinx-build) is not found, not generating documentation")
      return()
    endif()

    add_custom_target(${CMAKEME_SPHINX_PYTHON_PACKAGE}_docs ALL
            COMMAND ${SPHINX_EXECUTABLE}
            -b html
            -a
            ${CMAKE_BINARY_DIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE}
            ${CMAKE_BINARY_DIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE}/html
            > build-html.log
            COMMENT "sphinx-build html: see build-html.log"
            VERBATIM
            )

    if(CMAKEME_SPHINX_PYTHON_DEPENDS)
      add_dependencies(${CMAKEME_SPHINX_PYTHON_PACKAGE}_docs ${CMAKEME_SPHINX_PYTHON_DEPENDS})
    endif()

    install(DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE}/html DESTINATION ${CMAKE_INSTALL_DOCDIR}/${CMAKEME_SPHINX_PYTHON_PACKAGE})

  endif()
endfunction()
