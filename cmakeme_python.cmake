#[=======================================================================[.rst:
cmakeme_python
----------------
Manage and install python packages that are linked to C++ projects

Use this module with ``find_package(cmakeme)``

#]=======================================================================]




#[=======================================================================[.rst:
Commands
^^^^^^^^
    .. command:: cmakeme_python_package

    Creates a python package installable from pip by invoking the appropriate setup.py

        .. code-block:: cmake

            cmakeme_python(setup directory pkgname)

        ``directory``
        Absolute path to the directory containing setup.py/setup.cfg

        ``pkgname``
        The name of the python package
#]=======================================================================]
# TODO: this is deprecated so fix when we bump minimum cmake version
find_package(PythonInterp)

function(cmakeme_python directory pkgname)
  if(PYTHONINTERP_FOUND)
    # If we are in a virtual/conda environment
    # (see https://www.scivision.dev/cmake-install-python-package/
    # Accessed 06/05/2022
    if(DEFINED ENV{VIRTUAL_ENV} OR DEFINED ENV{CONDA_PREFIX})
      set(_pip_args)
    else()
      set(_pip_args "--user")
    endif()
    # Build the wheel during code generation time
    set(outdir "${CMAKE_BINARY_DIR}/${pkgname}/dist")
    add_custom_target(${pkgname} ALL ${CMAKE_COMMAND} -E make_directory ${outdir})
    add_custom_command(TARGET ${pkgname}
      COMMAND ${PYTHON_EXECUTABLE}
      ARGS -m build ${directory} --outdir ${outdir}
      )
  else()
    message(WARNING "Cannot cmakeme_python because Python Interpreter not found")
  endif()
endfunction()
