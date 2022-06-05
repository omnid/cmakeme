# CMake Me
A library of CMake utilities for installing executables and libraries,
setting default compiler flags, accessing git commit hashes and
hashes of source files at compile time.  

# Basic Usage
```cmake
find_package(cmakeme)   # Use this package
cmakeme_defaults(Debug) # Default build type is Debug for single-generator builds

find_package(MyDependency) # bring in a dependency

# add a library, as usual cmakeme_flags contains some default C and C++ flags
# that are generally useful (such as enabling warnings)
add_library(my_lib src/file1.cpp src/file2.cpp)
target_link_libraries(my_lib PUBLIC MyDependency::dep1 cmakeme_flags)

# We do not need to add include directories to the install interface
target_include_directories(my_lib
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)

# Simplify the installation process. Users of this library are able to
# find_package(my_lib) then target_link_libraries(target PUBLIC my_lib::my_lib
cmakeme_install(TARGETS my_lib NAMESPACE my_lib DEPENDS MyDependency)

# Generate doxygen documentation from source files, and use the README.md as the first page
cmakeme_doxygen(README.md src/)

# Let the developer create binary packages for various systems by running `make package`
cmakeme_package(EMAIL myemail@website.com ARCH_64
                DEBIAN_DEPENDS dep1 dep2 ARCHLINUX_DEPENDS dep1a dep2a)
```
For more details, see the [API Documentation](https://omnid.github.io/cmakeme)    
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
5. Specify `-DBUILD_SPHINX_CMAKE=On` to build the developer documentation for this package.
6. Read the [detailed API documentation](https://omnid.github.io/cmakeme).    

# Summary
To use any of the modules:
`find_package(cmakeme)`

The available modules are documented in the [detailed API documentation](https://omnid.github.io/cmakeme).
1. `cmakeme-config`: Loads other modules. Provides `cmakeme_flags`, a target that provides default C/C++ flags.
2. `cmakeme_defaults`: CMake library for setting default options like the build type.
3. `cmakeme_install`: Simplify cmake library installation for some common scenarios
4. `git_hash`: Access git hash information from your C and C++ code
5. `cmakeme_cpack`: Create binary installers for debian, archlinux, and other platforms
6. `cmakeme_doxygen`: Simplify doxygen use by providing common default options
7. `sphinx_cmake`: Create official-looking CMake documentation using sphinx.
