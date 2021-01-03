cmakeme_config
--------------

Find cmakeme. This module is called when using ``find_package(cmakeme)``.  It brings in the other ``cmakeme`` modules.

Libraries
^^^^^^^^^
.. variable:: cmakeme_flags 

Interface library containing compile flags with options that enable many compiler warnings, C++17, and C99 (for gcc, clang and TI compilers).

Result Variables
^^^^^^^^^^^^^^^^

.. variable:: cmakeme_FOUND

True if cmakeme is found

.. variable:: CMAKEME_ROOT_DIR

Base directory of the cmakeme package
