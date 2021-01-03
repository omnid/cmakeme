#[=======================================================================[.rst:
cmakeme_defaults
----------------
Basic helper functions providing some useful generic cmake features

Use this module with ``find_package(cmakeme)``

#]=======================================================================]


#[=======================================================================[.rst:
Variables
^^^^^^^^^
.. variable:: BUILD_DOCS

Default (``OFF``) set to (``ON``) to build all the documentation for a cmakeme project
#]=======================================================================]
option(BUILD_DOCS "Build all of the documentation generated using cmakeme" OFF)
if(BUILD_DOCS)
    set(BUILD_DOXYGEN ON CACHE BOOL "Overriden by BUILD_DOCS" FORCE)
    set(BUILD_SPHINX_CMAKE ON CACHE BOOL "Overriden by BUILD_DOCS" FORCE)
endif()


#[=======================================================================[.rst:
Commands
^^^^^^^^
    .. command:: cmakeme_defaults

        Sets up all of the default settings from cmakeme:
        1. Sets a default build type (single-configuration generators, and is user-overridable with ``-DCMAKE_BUILD_TYPE=``)
        2. Disables in-source builds (prevent accidentally polluting the source space)
        3. Disables language extensions

        .. code-block:: cmake

            cmakeme_defaults(type)

        ``type``
        The build type to set as the default type.
        (Release, Debug, RelWithDebInfo, MinSizeRel, or "")
#]=======================================================================]
macro(cmakeme_defaults type)
  cmakeme_disable_in_source_builds()
  cmakeme_set_default_build_type(${type})
  cmakeme_no_lang_extensions()
endmacro()


# type - the build type to set
# type - the default release type, None Debug Release RelWithDebInfo MinSizeRel

#[=======================================================================[.rst:
    .. command:: cmakeme_set_default_build_type
        
        Set a default build type if not specified and store it in the cache.
        The default type specified the developer can still be overriden by a 
        user when they generate the build system.

        .. code-block:: cmake
        
            cmakeme_set_default_build_type(type)

        ``type``
        The build type to set as the default type (Release, Debug, RelWithDebInfo, MinSizeRel, or "")
#]=======================================================================]
macro(cmakeme_set_default_build_type type)
  set(DEFAULT_BUILD_TYPE ${type})
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${DEFAULT_BUILD_TYPE} CACHE
      STRING "Type of build." FORCE)

    message(STATUS "CMAKE_BUILD_TYPE=\"\": Defaulting to ${DEFAULT_BUILD_TYPE}")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
  endif()
endmacro()

#[=======================================================================[.rst:
    .. command:: cmakeme_disable_in_source_builds

        Disable in-source builds of the project so that it is an error to
        configure a project from within the source directory. 
        This feature presents litering the source code directory with 
        CMake files; however, you will need to manually delete CMakeFiles
        and CMakeCache.txt should you try an in-source build.

        .. code-block:: cmake

            cmakeme_disable_in_source_builds()
#]=======================================================================]
function(cmakeme_disable_in_source_builds)
  if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR
      "No in source builds allowed. Create a separate build directory.
       SOURCE_DIR=${CMAKE_SOURCE_DIR}  BINARY_DIR=${CMAKE_BINARY_DIR}.
       You may wish to delete CMakeCache.txt and CMakeFiles. ")
  endif()
endfunction()

#[=======================================================================[.rst:
    .. command:: cmakeme_no_lang_extensions 
    
        Disable c/c++ language extensions globally

    .. code-block:: cmake

        cmakeme_no_lang_extensions
#]=======================================================================]
macro(cmakeme_no_lang_extensions)
  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_C_EXTENSIONS OFF)
endmacro()

