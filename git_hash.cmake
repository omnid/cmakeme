#[=======================================================================[.rst:
git_hash
--------

    Generate git hashes for project source code and access them via constants
    defined in header files. You can retrieve the SHA1 hash that git uses for the 
    current commit, the SHA1 hash of any subset of files, and the current commit status
    (dirty or clean).

Usage
^^^^^
This module is included with ``find_package(cmakeme)`` and will automatically
generate a header file called ``${PROJECT_NAME}_git_hash.h``.

To use from your project (called ``myprojecct``)

.. code-block:: cpp
    
    #include"myproject/myproject_git_hash.h"
    // my_project_git_hash.h provides the following defines:
    #define GIT_HASH_HEAD  // The SHA1 hash of the HEAD of the git repository
    #define GIT_HASH_DIRTY // True if there are tracked files that have not been committed

.. note::

    Use ``${PROJECT_NAME}_git_hash.h`` sparingly because every file that includes it is recompiled
    every build.
#]=======================================================================]
find_package(Git REQUIRED)

# configure files to temporary directory so they cna be copied and given execute permissions
configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash.bash.in
  ${CMAKE_BINARY_DIR}/tmp/git_hash.bash @ONLY)

configure_file(${CMAKE_CURRENT_LIST_DIR}/git_hash_target.bash.in
  ${CMAKE_BINARY_DIR}/tmp/git_hash_target.bash @ONLY)

file(COPY ${CMAKE_BINARY_DIR}/tmp/git_hash.bash  ${CMAKE_BINARY_DIR}/tmp/git_hash_target.bash
  DESTINATION ${CMAKE_BINARY_DIR}
  FILE_PERMISSIONS
  OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
  )

# add the githash target
add_custom_target(git_hash ALL
  COMMAND ${CMAKE_BINARY_DIR}/git_hash.bash ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${PROJECT_NAME}_git_hash.h
  COMMENT "Updating ${PROJECT_NAME}_git_hash.h"
  BYPRODUCTS ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${PROJECT_NAME}_git_hash.h
  VERBATIM
  )

#[=======================================================================[.rst:
Commands
^^^^^^^^

.. command:: cmakeme_interface_libraries

The ``cmakeme_interface_libraries(library interface)`` function recursively traverses the INTERFACE_LINK_LIBRARIES brought in by linking against library

.. code-block:: cmake

  cmakeme_interface_libraries(library interface)

  ``library`` The name of the library.

  ``interface`` Name of variable that will contain a list of all libraries brought in as ``INTERFACE_LINK_LIBRARIES``

.. note::
   This is an internal function, but might be useful elsewhere
#]=======================================================================]

function(cmakeme_interface_libraries library interface)
  if(TARGET ${library})
    get_target_property(nextint ${library} INTERFACE_LINK_LIBRARIES)
    if(nextint)
      list(APPEND ${interface} ${nextint})
      foreach(inter ${nextint})
        cmakeme_interface_libraries(${inter} ${interface})
      endforeach()
    endif()
  endif()
  set(${interface} "${${interface}}" PARENT_SCOPE)
endfunction()
  
#[=======================================================================[.rst:
.. command:: cmakeme_hash

The ``cmakeme_hash(target)`` function hashes the files used for the specified target and its dependencies

.. code-block:: cmake

  cmakeme_hash(target)

``target`` The name of the target to hash.  The hash is the SHA1 hash of all the source files for the target and its dependencies.

For example, if the project name is ``myproject`` and the target name is ``mytarget``, 

.. code-block:: c

    #include"myproject/mytarget_git_hash.h"
    // The above include does the following
    #include"myproject/myproject_git_hash.h" // git hashes for the overall project
    #define GIT_HASH_mytarget // git hash for the specified target

.. note::    

  Include sparingly, as any file that includes the header file is recompiled every time you build.
#]=======================================================================]


function(cmakeme_hash target)
  get_target_property(githash_libs ${target} LINK_LIBRARIES)
  get_target_property(githash_sources ${target} SOURCES)
  get_target_property(githash_includes ${target} INCLUDE_DIRECTORIES)
  get_target_property(githash_srcdir ${target} SOURCE_DIR)


  # Gather up recursive interface libraries from the libraries that are linked against the target
  foreach(githash_lib ${githash_libs})
    cmakeme_interface_libraries(${githash_lib} githash_interface_libs)
  endforeach()

  # append each library location to the list of files to hash
  foreach(githash_lib IN LISTS githash_libs githash_interface_libs)
    if(TARGET ${githash_lib})
      # cmake Object libraries have a series of object files rather than a single object file name
      get_target_property(type ${githash_lib} TYPE)
      if(type STREQUAL OBJECT_LIBRARY)
        list(APPEND githash_files $<TARGET_OBJECTS:${githash_lib}>)
      elseif(type STREQUAL INTERFACE_LIBRARY)
        #  ignore interface libraries since they don't have files assocaited with them
        #  They are included from the recursive traversal, but it is only the endpoints of that
        # traversal that contain the actual dependencies that correspond to real files (I think)
      else()
        list(APPEND githash_files $<TARGET_FILE:${githash_lib}>)
      endif()
    endif()
  endforeach()

  # append each source file location to the list of files to hash
  list(APPEND githash_files ${githash_sources})
  # replace the semicolons in the list with spaces to separate files
  add_custom_target(git_hash_${target}
    COMMAND ${CMAKE_BINARY_DIR}/git_hash_target.bash ${target} ${CMAKE_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${target}_hash.h ${githash_files} ${githash_includes} ${githash_srcdir}/CMakeLists.txt
    COMMENT "Updating ${target}_hash.h"
    BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/cmakeme/include/${PROJECT_NAME}/${target}_hash.h
    VERBATIM
    )
  add_dependencies(${target} git_hash_${target} git_hash)
  target_include_directories(${target} PUBLIC $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/cmakeme/include>)
endfunction()
