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

The modules are documented in more detail the generated sphinx [documentation](https://omnid.github.io/cmakeme)
and summarized below:

## CMake Defaults
CMake library for setting some options and defaults 

## Install Helpers
CMake library for helping with some typical installation scenarios, provides the `cmakeme_install` function.

## Git Hash
CMake library for computing git hashes and incorporating them into your code.

## CPack Helpers
Create Debian, ArchLinux, and archives of the installation.

## Doxygen
Build doxygen documentation with minimal setup

## Sphinx CMake
Document CMake files with sphinx.
