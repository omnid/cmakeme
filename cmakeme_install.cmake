# Install a cmake target-specific library to the proper directories
include(GNUInstallDirs)

#[[ Install a target with the given name, according to cmakeme conventions.  
cmakeme_install(TARGET name
                [NAMESPACE ns]
                [INCLUDEDIRS incdir...] 
                [ARCH_INDEPENDENT]
                [DEPENDS dependencies...]
                [CONFIG config]
                )
* `name` - the name of the target to install. 
* `ns`     - Namespace for name. The target will be found using
             `find_package(ns)` and used by adding `ns::target` to `target_link_libraries`
* `incdir` - include directories that should be installed. The appropriate include directories
             are automatically added so that dependent projects can find them.
* `ARCH_INDEPENDENT` - Specify for header-only libraries or other libraries that
                       do not depend on being compiled for a specific target architecture.
* `dependencies` - Targets that target depends upon.
* `config` - The configuration file template to use. This file will be installed
             as `ns-config.cmake` and executed when a dependent project calls `find_package(ns)`
             It should `include` each `name-target.cmake` and use `find_dependency` to bring
             in any dependencies. May be omitted if you do not need to import the installed target
             from another cmake project.

Most of these options are useful for installing libraries. For an executable target the optional arguments can usually be omitted.
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
    "TARGET;NAMESPACE;CONFIG"
    "INCLUDEDIRS;DEPENDS"
    ${ARGN}
    )
  if(CMAKEME_UNPARSED_ARGUMENTS)
    message(ERROR "Unrecognized arguments to cmakeme_install")
  endif()

  if("TARGET" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    message(ERROR "Must specify a TARGET argument")
  endif()
    
  
  install(TARGETS ${CMAKEME_TARGET}  ${CMAKEME_DEPENDS}
    EXPORT ${CMAKEME_TARGET}-target
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION  ${libdir}
    ARCHIVE DESTINATION  ${libdir}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

  install(EXPORT ${CMAKEME_TARGET}-target 
    NAMESPACE ${CMAKEME_NAMESPACE}
    DESTINATION ${libdir}/${CMAKEME_TARGET}
    )


  target_include_directories(${CMAKEME_TARGET} INTERFACE
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})

  # install headers
  foreach(incdir ${CMAKEME_INCLUDEDIRS})
    install(DIRECTORY ${incdir} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
  endfor()

  # If we are making this importable from other cmake projects
  if(NOT "CONFIG" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    include(CMakePackageConfigHelpers)

    if(CMAKEME_ARCH_INDEPENDENT) 
      write_basic_package_version_file(
        ${CMAKEME_NAMESPACE}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        ARCH_INDEPENDENT
        )
    else()
      write_basic_package_version_file(
        ${CMAKEME_NAMESPACE}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        )
    endif()

    # Used in case we need to export directories from NuhalConfig.cmake
    configure_package_config_file(${CMAKEME_CONFIG}  ${CMAKEME_NAMESPACE}-config.cmake
      INSTALL_DESTINATION ${libdir}/${CMAKEME_NAMESPACE} PATH_VARS)

    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_NAMESPACE}-config.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_NAMESPACE}-config-version.cmake
      DESTINATION ${libdir}/${CMAKEME_NAMESPACE})
  endif()

endfunction()
