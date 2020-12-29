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
4. See [Installation](https://github.com/omnid/omnid_docs/blob/master/Installation.md) for more detailed instructions.
5. Specify `-DBUILD_SPHINX=On` to build the developer documentation for this package.
   
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
2. Sets the default build type to `buildtype` (This default is still overridable by specifying `-DCMAKE_BUILD_TYPE=`)
3. Disables non-standard C and C++ language extensions

## Install Helpers
CMake library for helping with some typical installation scenarios, provides the `cmakeme_install` function.


## Git Hash
CMake library for computing git hashes and incorporating them into your code.

Provides the ability to generate two header files at compile time: `git_hash.h`,
which provides the hash of the current commit and indicates if it is dirty and `<target>_hash.h
which provides a hash of all the files used by a given target.

To use:
`cmakeme_hash(target)`
- Then you include `${PROJECT_NAME}/${target}_hash.h` in a C file where `${target}` is the name of the cmake target and ${PROJECT_NAME} is the name of your cmake project
   - Defines GIT_HASH, the hash of the last commit
   - Defines GIT_HASH_DIRTY, which is true if there are uncommitted changes
   - Defines GIT_HASH_<TARGET>, the hash of the target's SOURCES, LINK_LIBRARIES, and the contents
     of header files in its include directories
   - This hash should change anytime the target changes
   - Include sparingly, as any file that includes git_hash.h will be recompiled anytime
     the repository changes

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

## Doxygen
Call `cmakeme_doxygen()` to build doxygen documentation in build/docs.
Assumes the existence of `Doxyfile.in` in the base source directory, and that file should set the OUTPUT_DIRECTORY to `@CMAKE_BINARY_DIR@/docs`
and prefix INPUT paths with `@CMAKE_CURRENT_SOURCE_DIR@`
