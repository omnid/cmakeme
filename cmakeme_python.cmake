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

            cmakeme_python(directory pkgname)

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

  # directory where the whl file is extracted
  set(wheeldir ${outdir}/extracted_whl/${pkgname})

  # This target makes the directory where the wheel will be extracted
  # It must be it's own target because it must happen prior to
  # the $[pkgname}-python target's WORKING_DIRECTORY being set
  add_custom_target(${pkgname}-make-wheel-dir ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${wheeldir}
    )

  # This target builds the wheel and then extracts it to the directory specified by WORKING_DIRECTORY
  # (we use WORKING_DIRECTORY because cmake -E tar has no way to specify an output directory)
  add_custom_target(${pkgname}-python ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${outdir}
    COMMAND ${Python3_EXECUTABLE} -m build --wheel --outdir ${outdir} ${directory}
    COMMAND ${CMAKE_COMMAND} -E tar x ${outdir}/${pkgname}-*.whl --format=zip
    WORKING_DIRECTORY ${wheeldir}
    DEPENDS ${pkgname}-make-wheel-dir
    )

  # The wheel was extracted by ${pkgname}-python, now it just needs to be installed
  # The ending slash is so that the top-level directory is not copied
  install(DIRECTORY ${wheeldir}/
    DESTINATION "lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages")

endfunction()
