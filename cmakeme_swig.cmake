#[=======================================================================[.rst:
cmakeme_swig
----------------
Easily generate python bindings for simple C programs, without writing any
SWIG interface files. Doxygen comments from the C program will be carried
over to the python bindings.

Use this module with ``find_package(cmakeme)``

#]=======================================================================]

#[=======================================================================[.rst:
Commands
^^^^^^^^
    .. command:: cmakeme_swig

    Generate SWIG bindings to wrap a C library with python.

        .. code-block:: cmake

            cmakeme_swig_python(LIBRARY target HEADERS header1.h header2.h)

        ``LIBRARY``
        The name of the C library that should be wrapped. This will also be the name of the
        python wrapper module. This function supports only one python wrapper module per C library,

        ``HEADERS``
        The headers containing the definitions for which bindings should be generated.

#]=======================================================================]

function(cmakeme_swig)
  if(NOT SWIG_FOUND)
    find_package(SWIG REQUIRED COMPONENTS python)
    include(UseSWIG)
  endif()

  # Parse the arguments
  cmake_parse_arguments(
    CMAKEME_SWIG
    ""
    "LIBRARY"
    "HEADERS"
    ${ARGN}
    )
  if(CMAKEME_SWIG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments to cmakeme_install: ${CMAKEME_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT DEFINED CMAKEME_SWIG_LIBRARY)
    message(FATAL_ERROR "Must specify a LIBRARY argument")
  endif()

  if(NOT DEFINED CMAKEME_SWIG_HEADERS)
    message(FATAL_ERROR "Must specify a HEADERS argument")
  endif()

  list(LENGTH CMAKEME_SWIG_HEADERS header_len)
  if(header_len EQUAL 0)
    message(FATAL_ERROR "Must specify at least one header file in the HEADERS argument")
  endif()

  # Generate the .i file
  set(swig_file ${CMAKE_BINARY_DIR}/${CMAKEME_SWIG_LIBRARY}/${CMAKEME_SWIG_LIBRARY}.i)
  file(WRITE  ${swig_file}
    "%module ${CMAKEME_SWIG_LIBRARY}\n"
    "%{\n")

  foreach(header ${CMAKEME_SWIG_HEADERS})
    file(APPEND ${swig_file}
      "#include \"${header}\"\n")
  endforeach()
  file(APPEND ${swig_file} "%}\n")

  foreach(header ${CMAKEME_SWIG_HEADERS})
    file(APPEND ${swig_file}
      "#include \"${header}\"\n")
  endforeach()

  # Add the swig library
  swig_add_library(${CMAKEME_SWIG_LIBRARY}_swig LANGUAGE python SOURCES ${CMAKEME_SWIG_LIBRARY}.i)
  target_link_libraries(${CMAKEME_SWIG_LIBRARY}_swig ${CMAKEME_SWIG_LIBRARY} Python::Python)
  set_property(SOURCE ${CMAKEME_SWIG_LIBRARY}.i PROPERTY SWIG_MODULE_NAME ${CMAKEME_SWIG_LIBRARY})
  set_property(TARGET ${CMAKEME_SWIG_LIBRARY} PROPERTY SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON)
  set_property(TARGET ${CMAKEME_SWIG_LIBRARY} PROPERTY SWIG_COMPILE_OPTIONS -doxygen) # carry over doxygen comments to python
endfunction()
