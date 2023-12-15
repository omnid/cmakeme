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

    Uses a package's setup.cfg/setup.py/pyproject.toml to build and install a package locally on the machine.
    The wheel file is created and saved in the build directory.
    When install is run, the wheel is installed relative to the CMAKE_INSTALL_PREFIX.
    When installing to the system or to a ROS workspace this will put the python package directly on the path.
    Otherwise you will need to explicitly add the install path to the PYTHONPATH.

        .. code-block:: cmake

            cmakeme_python(setup directory pkgname)

        ``directory``
        Absolute path to the directory containing setup.py/setup.cfg

        ``pkgname``
        The name of the python package
#]=======================================================================]

function(cmakeme_python directory pkgname)
  if(NOT Python3_Interpreter_FOUND)
    find_package(Python3 REQUIRED COMPONENTS Interpreter )
  endif()

  # Build the wheel during code generation time
  set(outdir "${CMAKE_BINARY_DIR}/dist")

  # This target actually builds the wheel
  add_custom_target(${pkgname}-python ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${outdir}
    COMMAND ${Python3_EXECUTABLE} -m build ${directory} --outdir ${outdir}
    )

  # This target gets the wheel filename (which is difficult to compute beforehand)
  add_custom_target(${pkgname}-python-wheel ALL
    COMMAND ${CMAKE_COMMAND} -E echo ${outdir}/${pkgname}-*.whl > ${outdir}/${pkgname}-wheel-name
    DEPENDS ${pkgname}-python
    )

  # Install the wheel. This requires us to read the wheel name and then use it to install. We must remove the old wheel first
  # Note: Use OUTPUT_VARIABLE to capture output of execute_process. Results can be output using message(), which is useful for debugging
  install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E cat ${outdir}/${pkgname}-wheel-name OUTPUT_VARIABLE wheel_name)
                execute_process(COMMAND ${Python3_EXECUTABLE} -m pip install --force-reinstall --prefix ${CMAKE_INSTALL_PREFIX} \${wheel_name})")
endfunction()
