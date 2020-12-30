cmakeme_config
--------------

Find cmakeme. This module is called when using ``find_package(cmakeme)``.
It brings in all of the ``cmakeme`` modules.

Libraries
^^^^^^^^^

``cmakeme_flags`` 
  Interface library containing compile flags with options that enable many compiler warnings, C++17, and C99 (for gcc, clang and TI compilers).

Result Variables
^^^^^^^^^^^^^^^^

``cmakeme_FOUND``
  True if cmakeme is found

``CMAKEME_ROOT_DIR``
  Base directory of the cmakeme package
