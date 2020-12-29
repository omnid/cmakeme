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

Detailed API documentation can be found [here](https://omnid.github.io/cmakeme).

A summary of the features is below:
1. `cmakeme_defaults`: CMake library for setting default options like the build type.
2. `cmakeme_install`: Simplify cmake library installation for some common scenarios
3. `git_hash`: Access git hash information from your C and C++ code
4. `cmakeme_cpack`: Create binary installers for debian, archlinux, and other platforms
5. `cmakeme_doxygen`: Simplify doxygen use by providing common default options
6. `sphinx_cmake`: Create official-looking CMake documentation using sphinx.
