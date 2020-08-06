# Install a cmake target-specific library to the proper directories

# fake a language being enabled if it was not to suprress warnings from GNUInstallDirs
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

#[[ Install a target with the given name, according to cmakeme conventions.  
cmakeme_install(TARGET name
                [NAMESPACE ns]
                [INCLUDEDIRS incdir...] 
                [ARCH_INDEPENDENT]
                [DEPENDS dependencies...]
                [CONFIG config] [AS find-name]
                )
* `name` - the name of the target to install. 
* `ns`     - Namespace for name. Do not include the `::` after the namespace. The target will be found using
             `find_package(ns)` and used by adding `ns::target` to `target_link_libraries`
* `incdir` - include directories that should be installed. The appropriate include directories
             are automatically added to the INSTALL_INTERFACE so that dependent projects can find them.
             You must add them to the BUILD_INTERFACE if they are needed at buildtime     
* `ARCH_INDEPENDENT` - Specify for header-only libraries or other libraries that
                       do not depend on being compiled for a specific target architecture.
* `dependencies` - Targets that target depends upon that should be included in the export set.
                   (i.e., if the target is already installed within your project you don't need to include it here,
                    but if cmake complains then add it)
* `config` - The configuration file template to use. This file will be installed
             as `find-name-config.cmake` and executed when a dependent project calls `find_package(find-name)`
             It should `include` each `name-target.cmake` and use `find_dependency` to bring
             in any dependencies. May be omitted if you do not need to import the installed target
             from another cmake project.
* `find-name` - name of the module when importing to `CMake` via `find_package`.  This defaults to the value of `ns`

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
    "TARGET;NAMESPACE;CONFIG;AS"
    "INCLUDEDIRS;DEPENDS"
    ${ARGN}
    )
  if(CMAKEME_UNPARSED_ARGUMENTS)
    message(ERROR "Unrecognized arguments to cmakeme_install")
  endif()

  if("TARGET" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    message(ERROR "Must specify a TARGET argument")
  endif()
    
  target_include_directories(${CMAKEME_TARGET} INTERFACE
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}>)

  install(TARGETS ${CMAKEME_TARGET}  ${CMAKEME_DEPENDS}
    EXPORT ${CMAKEME_TARGET}-target
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION  ${libdir}
    ARCHIVE DESTINATION  ${libdir}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

  install(EXPORT ${CMAKEME_TARGET}-target 
    NAMESPACE ${CMAKEME_NAMESPACE}::
    DESTINATION ${libdir}/${CMAKEME_TARGET}
    )



  # install headers
  foreach(incdir ${CMAKEME_INCLUDEDIRS})
    file(GLOB_RECURSE files RELATIVE ${incdir} "${incdir}/*")
    foreach(file ${files})
      get_filename_component(filedir ${file} DIRECTORY)
      install(FILES ${incdir}/${file}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${filedir})
    endforeach()
  endforeach()

  # If we are making this importable from other cmake projects
  if(NOT "CONFIG" IN_LIST CMAKEME_KEYWORDS_MISSING_VALUES)
    include(CMakePackageConfigHelpers)

    if(NOT CMAKEME_AS)
      set(CMAKEME_AS ${CMAKEME_NAMESPACE})
    endif()

    if(CMAKEME_ARCH_INDEPENDENT) 
      write_basic_package_version_file(
        ${CMAKEME_AS}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        ARCH_INDEPENDENT
        )
    else()
      write_basic_package_version_file(
        ${CMAKEME_AS}-config-version.cmake
        COMPATIBILITY SameMajorVersion
        )
    endif()

    # Used in case we need to export directories from NuhalConfig.cmake
    configure_package_config_file(${CMAKEME_CONFIG}  ${CMAKEME_AS}-config.cmake
      INSTALL_DESTINATION ${libdir}/${CMAKEME_AS} PATH_VARS)

    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_AS}-config.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKEME_AS}-config-version.cmake
      DESTINATION ${libdir}/${CMAKEME_AS})
  endif()

endfunction()
