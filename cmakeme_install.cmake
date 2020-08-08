# Install a cmake target-specific library to the proper directories

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

#[[
    Install the specified targets. If the target is a library its INTERFACE include directories will also be installed
    and the appropriate paths will be added to the exported library. If the target has INTERFACE_SOURCES these will
    be installed as well.
cmakeme_install(TARGETS targets... 
                [NAMESPACE ns]
                [ARCH_INDEPENDENT]
                [PACKAGE_NAME name]
                [DEPENDS deps..]
                )
* `targets - The targets that should be installed. This is the only option necessary if the targets do not need to be
             found by other cmake modules.
* `ns`     - Namespace for name. If not specified the targets will not be exported. Do not include the `::` after the namespace.
             Link against the configured targets by passing `ns::target` to `target_link_libraries`
* `ARCH_INDEPENDENT` - Specify for an architecture-independent library, such as a header-only library.
* `name` - The name of the package, as used by `find_package`. So the package will be imported via `find_package(name)`
           defaults to the value of `ns`
* `deps` - The dependencies of the listed targets that should be found when `find_package(name)` is called
           In other words, imported dependencies that are required for using the target

Use `target_include_directories(target INTERFACE $<BUILD_INTERFACE:directory>) to add include directories
and `target_sources(target INTERFACE $<BUILD_INTERFACE:source>)` to add source files.  The `$<BUILD_INTERFACE:>`
generator expression only adds the items in it during build time.  At install time, the location of the files
moves.  `cmakeme_install` will add the proper paths to the `$<INSTALL_INTERFACE:>` for use at installation time.
]]

function(cmakeme_install)
  if(CMAKE_CROSSCOMPILING)
    set(libdir ${CMAKE_INSTALL_LIBDIR}/${CMAKE_LIBRARY_ARCHITECTURE})
  else()
    set(libdir ${CMAKE_INSTALL_LIBDIR})
  endif()

  cmake_parse_arguments(
    "CMAKEME"
    "ARCH_INDEPENDENT"
    "NAMESPACE;PACKAGE_NAME"
    "TARGETS;DEPENDS"
    ${ARGN}
    )
  if(CMAKEME_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments to cmakeme_install: ${CMAKEME_UNPARSED_ARGUMENTS}")
  endif()

  if("TARGETS" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Must specify a TARGET argument")
  endif()

  if("PACKAGE_NAME" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    set(CMAKEME_PACKAGE_NAME ${CMAKEME_NAMESPACE})
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
      # then make sure that the include file is from within the project and
      # not something that comes from an external project
      string(FIND ${incdir} ${CMAKE_CURRENT_SOURCE_DIR} starts_with)
      if(starts_with EQUAL 0)
        # make sure the directory ends with a /
        string(APPEND incdir "/")
        string(REPLACE "//" "/" incdir ${incdir})
        install(DIRECTORY ${incdir} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
      endif()
    endforeach()

    get_target_property(srcs ${target} INTERFACE_SOURCES)
    foreach(src in ${src})
      # First, remove $<BUILD_INTERFACE:> generator expression to get the directory
      string(REGEX REPLACE "\\$<BUILD_INTERFACE:(.*)>" "\\1" src ${src})
      # Next, ensure that the source file is from with the project
      string(FIND ${src} ${CMAKE_CURRENT_SOURCE_DIR} starts_with)
      if(starts_with EQUAL 0)
        get_filename_component(fname ${src} NAME)
        install(FILES ${src} DESTINATION ${CMAKE_INSTALL_PREFIX}/${libdir}/src/)
      endif()
    endforeach()
  endforeach()

  
  install(TARGETS ${CMAKEME_TARGETS}
    EXPORT ${CMAKEME_PACKAGE_NAME}-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION  ${libdir}
    ARCHIVE DESTINATION  ${libdir}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

  install(EXPORT ${CMAKEME_PACKAGE_NAME}-targets
    NAMESPACE ${CMAKEME_NAMESPACE}::
    DESTINATION ${libdir}/${CMAKEME_PACKAGE_NAME}
    )


  # If we are making this importable from other cmake projects
  if(NOT "NAMESPACE" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    include(CMakePackageConfigHelpers)

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
