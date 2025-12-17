cmakeme_config
--------------

Find cmakeme. This module is called when using ``find_package(cmakeme)``.  It brings in the other ``cmakeme`` modules.

Libraries
^^^^^^^^^
.. variable:: cmakeme_flags 

Interface library containing compile flags with options that enable many compiler warnings, C++17, and C99 (for gcc, clang and TI compilers).
On gcc/clang, this library also configures the `__FILE__`  macro to be reproducible: it will only display paths relative to the project directory.

Configuration Variables
^^^^^^^^^^^^^^^^^^^^^^^
.. variable:: BUILD_DOCS

Default (``OFF``) set to (``ON``) to build all the documentation for a cmakeme project

Result Variables
^^^^^^^^^^^^^^^^

.. variable:: cmakeme_FOUND

True if cmakeme is found

.. variable:: CMAKEME_ROOT_DIR

Base directory of the cmakeme package

#[=======================================================================[.rst:
