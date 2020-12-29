#[=======================================================================[.rst:
cmakeme_defaults
----------------
Basic helper functions providing some useful generic cmake features
#]=======================================================================]

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
    The build type to set as the default type (Release, Debug, RelWithDebInfo, MinSizeRel, or "")
#]=======================================================================]
macro(cmakeme_defaults type)
  cmakeme_disable_in_source_builds()
  cmakeme_set_default_build_type(${type})
  cmakeme_no_lang_extensions()
endmacro()

# set a default build type if not specified and store it in the cache
# type - the build type to set
# type - the default release type, None Debug Release RelWithDebInfo MinSizeRel
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

# disable in source builds. So if you try to configure a project
# from within the source directory you will get an error.
# instaed of litering the directory with files you just need
# to delete CMakeFiles and CMakeCache.txt
function(cmakeme_disable_in_source_builds)
  if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR
      "No in source builds allowed. Create a separate build directory.
       SOURCE_DIR=${CMAKE_SOURCE_DIR}  BINARY_DIR=${CMAKE_BINARY_DIR}.
       You may wish to delete CMakeCache.txt and CMakeFiles. ")
  endif()
endfunction()

# disable c/c++ language extensions
macro(cmakeme_no_lang_extensions)
  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_C_EXTENSIONS OFF)
endmacro()

