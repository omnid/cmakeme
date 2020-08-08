# CMake Me
A library of CMake utilities for installing executables and libraries,
setting default compiler flags, accessing git commit hashes and
hashes of source files at compile time.  

# Installation
1. This project has no dependencies (other than `cmake` and optionally `git`, `bash`, and `find`).

There are three options for installing:
1. Install a [binary release](https://github.com/omnid/cmakeme/releases)
2. Clone into and build from a ROS workspace 
3. Clone the repository and build it like a typical CMake project
   ```
   cd cmakeme
   cmake -B build .
   cmake --build build
   cmake --build build --target install
   ```
4. See (Installation)[https://github.com/omnid/omnid_docs/blob/master/Installation.md] for more detailed instructions.
   
# Modules
To use any of the modules:
`find_package(cmakeme)`

## CMake Defaults
CMake library for setting some options and defaults 
```
cmakeme_defaults(buildtype)
```
Sets up some default settings including:
1. Disables in-source builds. 
2. Sets the default build type to `buildtype`
3. Disables non-standard C and C++ language extensions

## Install Helpers
CMake library for helping with some typical installation scenarios, provides the `cmakeme_install` function.

For example, 
```
add_executable(target1 file1.c file2.c)
add_library(lib1 file3.c)
target_linke_libraries(lib1 PUBLIC dep1)
target_include_directories(lib1 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)
cmakeme_install(TARGETS target1 lib1 NAMESPACE mylib DEPENDS dep1)
```
Once installed the library `lib1` can then be used from another cmake project:
```
find_package(mylib)
...
target_link_libraries(lib2 PUBLIC mylib::lib1)
```

You can usually use the above code as a guide, but there are more options and features,
see comments in `cmakeme_install.cmake` for the full documentation.

## Git Hash
CMake library for computing git hashes and incorporating them into your code.

Provides the ability to generate two header files at compile time: `git_hash.h`,
which provides the hash of the current commit and indicates if it is dirty and `<target>_hash.h
which provides a hash of all the files used by a given target.

1. To Load `git_hash`: `find_package(git_hash)`
2. To create `git_hash.h`: git_hash()
   - Defines GIT_HASH, the hash of the last commit
   - Defines GIT_HASH_DIRTY, which is true if there are uncommitted changes
   - Include sparingly, as any file that includes git_hash.h will be recompiled anytime
     the repository changes
3. To create `<target>_hash.h`: git_hash_target(target)
   - Defines <TARGET>_HASH, the hash of the target's SOURCES, LINK_LIBRARIES, and the contents
     of header files in its include directories
   - This hash should change anytime the target changes

## CPack functionality
Create Debian, ArchLinux, and archives of the installation.
Building the packages is triggered with `cpack` or the `package` target (e.g., `make package`)
See `cpack/cmakeme_pack.cmake` for details
```
cmakeme_package(EMAIL email
                [ARCH_64 | ARCH_ANY ]
                [DEBIAN_DEPENDS d1...]
                [DEBIAN_RECOMMENDS r1 ...]
                [ARCHLINUX_DEPENDS a1...]
                [ARCHLINUX_RECOMMENDS a1...]
                )
```