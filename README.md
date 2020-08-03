# CMake Git Hash
CMake library for computing git hashes and incorporating them into your code.

Provides the ability to generate two header files at compile time: `git_hash.h`,
which provides the hash of the current commit and indicates if it is dirty and `<target>_hash.h
which provides a hash of all the files used by a given target.

# Installation
Install like a standard cmake project
```
git clone https://github.com/omnid/cmake_git_hash.git
cd cmake_git_hash
cmake -B build . -DCMAKE_INSTALL_PATH=$INSTALL_DIR
cmake --build build
cmake --build build --target install
```
Omit $INSTALL_DIR for system-wide installation

# Usage
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