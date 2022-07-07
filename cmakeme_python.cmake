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

    Uses a package's setup.cfg/setup.py to build and install a package locally on the machine.
    The wheel file is created and saved in the build directory.
    When install is run, the wheel is installed relative to the CMAKE_INSTALL_PREFIX.
    When installing to the system or to a ROS workspace this will put the python package directly on the path. Otherwise you will need to explicitly add the install path to the PYTHONPATH.

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
    # Build the wheel during code generation time
    set(outdir "${CMAKE_BINARY_DIR}/${pkgname}/dist")
    add_custom_target(${pkgname}-python ALL ${CMAKE_COMMAND} -E make_directory ${outdir})
    add_custom_command(TARGET ${pkgname}-python
      COMMAND ${PYTHON_EXECUTABLE}
      ARGS -m build ${directory} --outdir ${outdir}
      )
    # Install the wheel. This requires
    install(CODE "file(GLOB wheels LIST_DIRECTORIES false \"${outdir}/*.whl\")
                  message(\"Wheel is \${wheels}\")
                  execute_process(COMMAND ${PYTHON_EXECUTABLE} -m pip install --prefix ${CMAKE_INSTALL_PREFIX} \${wheels})"
      )
  else()
    message(WARNING "Cannot cmakeme_python because Python Interpreter not found")
  endif()
endfunction()
