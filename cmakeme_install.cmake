#[=======================================================================[.rst:
cmakeme_install
---------------
Helper function for typical cmake installation scenarios.
#]=======================================================================]

# fake a language being enabled if it was not to supress warnings from GNUInstallDirs
# This is a hack, but it is possible to want to know install directories without actually
# compiling anything
if(NOT DEFINED CMAKE_SYSTEM_NAME OR NOT DEFINED CMAKE_SIZEOF_VOID_P)
  set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
  set(CMAKE_SIZEOF_VOID_P 8)
  include(GNUInstallDirs)
  unset(CMAKE_SYSTEM_NAME)
  unset(CMAKE_SIZEOF_VOID_P)
else()
  include(GNUInstallDirs)
endif()

#[=======================================================================[.rst:
Commands
^^^^^^^^

.. command:: cmakeme_install

    The ``cmakeme_install()`` function installs the specified targets along
    with any include files in ``INTERFACE_INCLUDE_DIRECTORIES`` or source files 
    in ``INTERFACE_SOURCES``. If the target is a library it will be setup to be
    imported from other cmake files. 

    .. code-block:: cmake

      cmakeme_install(TARGETS targets... 
                [NAMESPACE ns]
                [ARCH_INDEPENDENT]
                [PACKAGE_NAME name]
                [DEPENDS deps..]
                )

    ``TARGETS targets`` 
    The targets that should be installed.
    This is the only option necessary if the targets do not need to be found by other cmake modules.
    If target.bin is also defined as a target it will be installed as well.

    ``NAMESPACE ns`` 
    Namespace for name.
    If not specified the targets will not be exported.
    Do not include the `::` after the namespace.  
    Link against the configured targets by passing `ns::target` to `target_link_libraries`
    
    ``ARCH_INDEPENDENT``
    Specify for an architecture-independent library, such as a header-only library.

    ``PACKAGE_NAME name`` 
    The name of the package, as used by `find_package`. So the package will be imported via `find_package(name)` defaults to the value of `ns`

    ``DEPENDS deps``:w
    The dependencies of the listed targets that should be found when `find_package(name)` is called.
    In other words, imported dependencies that are required for using the target

    .. note::
        Use ``target_include_directories(target INTERFACE $<BUILD_INTERFACE:directory>)`` to add include directories 
        and ``target_sources(target INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source1>... )`` to add source files.
        The ``$<BUILD_INTERFACE:>`j` generator expression only adds the items in it during build time.
        At install time, the location of the files moves.
        ``cmakeme_install`` will add the proper paths to the ``$<INSTALL_INTERFACE:>`` for use at installation time.
#]=======================================================================]

function(cmakeme_install)

  cmake_parse_arguments(
    CMAKEME
    "ARCH_INDEPENDENT"
    "NAMESPACE;PACKAGE_NAME"
    "TARGETS;DEPENDS"
    ${ARGN}
    )
  if(CMAKEME_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments to cmakeme_install: ${CMAKEME_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT DEFINED CMAKEME_TARGETS)
    message(FATAL_ERROR "Must specify a TARGETS argument")
  endif()

  if(NOT DEFINED CMAKEME_PACKAGE_NAME)
    set(CMAKEME_PACKAGE_NAME ${CMAKEME_NAMESPACE})
  endif()

  # setup architecture specific directories if cross-compiling and there is no architecture-independent code
  if(CMAKE_CROSSCOMPILING AND (NOT CMAKEME_ARCH_INDEPENDENT))
    set(libdir ${CMAKE_INSTALL_LIBDIR}/${CMAKE_LIBRARY_ARCHITECTURE})
    set(bindir ${CMAKE_INSTALL_BINDIR}/${CMAKE_LIBRARY_ARCHITECTURE})
  else()
    set(libdir ${CMAKE_INSTALL_LIBDIR})
    set(binder ${CMAKE_INSTALL_BINDIR})
  endif()

  # Automatically find the header files that are included, install them,
  # and add them to the interface include directories
  foreach(target ${CMAKEME_TARGETS})
    get_target_property(dirs ${target} INTERFACE_INCLUDE_DIRECTORIES)
    if(dirs)
      target_include_directories(${target} INTERFACE
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
    endif()

    foreach(incdir ${dirs})
      # if the include directory is within the source code we should install it.
      # First, remove $<BUILD_INTERFACE:> generator expression to get the directory
      string(REGEX REPLACE "\\$<BUILD_INTERFACE:(.*)>" "\\1" incdir ${incdir})
      # then make sure that the include file is from within the project (either the source directory or generated in the build directory) and
      # not something that comes from an external project
      string(FIND ${incdir} ${CMAKE_CURRENT_SOURCE_DIR} starts_with_source)
      string(FIND ${incdir} ${CMAKE_CURRENT_BINARY_DIR} starts_with_bin)
      if((starts_with_source EQUAL 0) OR (starts_with_bin EQUAL 0))
        # make sure the directory ends with a /
        string(APPEND incdir "/")
        string(REPLACE "//" "/" incdir ${incdir})
        install(DIRECTORY ${incdir} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
      endif()
    endforeach()

    get_target_property(srcs ${target} INTERFACE_SOURCES)
    foreach(src ${srcs})
      # First, remove $<BUILD_INTERFACE:> generator expression to get the directory
      string(REGEX REPLACE "\\$<BUILD_INTERFACE:(.*)>" "\\1" src ${src})
      # Next, ensure that the source file is from with the project
      string(FIND ${src} ${CMAKE_CURRENT_SOURCE_DIR} starts_with)
      if(starts_with EQUAL 0)
        file(GLOB filerel RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${src})
        get_filename_component(reldir ${filerel} DIRECTORY)
        install(FILES ${src} DESTINATION ${CMAKE_INSTALL_PREFIX}/${libdir}/${target}/${reldir})
        # add the source to the install interface
        target_sources(${target} INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${libdir}/${target}/${filerel}>)
      endif()
    endforeach()
    get_target_property(mysrc ${target} INTERFACE_SOURCES)

    if(TARGET ${target}.bin)
      install(PROGRAMS $<TARGET_FILE:${target}>.bin DESTINATION ${bindir})
    endif()
  endforeach()

  
  install(TARGETS ${CMAKEME_TARGETS}
    EXPORT ${CMAKEME_PACKAGE_NAME}-targets
    RUNTIME DESTINATION ${bindir}
    LIBRARY DESTINATION  ${libdir}
    ARCHIVE DESTINATION  ${libdir}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )



  # If we are making this importable from other cmake projects
  if(DEFINED CMAKEME_NAMESPACE)
    include(CMakePackageConfigHelpers)

    install(EXPORT ${CMAKEME_PACKAGE_NAME}-targets
      NAMESPACE ${CMAKEME_NAMESPACE}::
      DESTINATION ${libdir}/${CMAKEME_PACKAGE_NAME}
      )

    if(CMAKEME_ARCH_INDEPENDENT) 
      write_basic_package_version_file(
        ${CMAKEME_PACKAGE_NAME}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        ARCH_INDEPENDENT
        )
    else()
      write_basic_package_version_file(
        ${CMAKEME_PACKAGE_NAME}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        )
    endif()

    # generate the package config file template
    file(WRITE ${CMAKE_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config.cmake.in
      "@PACKAGE_INIT@\n
       include(CMakeFindDependencyMacro)\n")
    file(APPEND ${CMAKE_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config.cmake.in
        "include(\${CMAKE_CURRENT_LIST_DIR}/${CMAKEME_PACKAGE_NAME}-targets.cmake)\n")

    foreach(dep ${CMAKEME_DEPENDS})
      file(APPEND ${CMAKE_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config.cmake.in
        "find_dependency(${dep})\n")
    endforeach()
    # The configure file is now generated it is a template designed to be used with configure_package_config_file
    
    # Used in case we need to export directories from NuhalConfig.cmake
    configure_package_config_file(${CMAKE_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config.cmake.in
      ${CMAKEME_PACKAGE_NAME}-config.cmake
      INSTALL_DESTINATION ${libdir}/${CMAKEME_PACKAGE_NAME} PATH_VARS)

    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_PACKAGE_NAME}-config-version.cmake
      DESTINATION ${libdir}/${CMAKEME_PACKAGE_NAME})
  endif()

endfunction()
