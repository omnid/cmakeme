#[=======================================================================[.rst:
cmakeme_pack
---------------
Simple wrapper around CPack. Create Debian, ArchLinux, and archives of the installation.
Building the packages is triggered with `cpack` or the `package` target (e.g., `make package`)
Essentially, this is a limited subset of cpack functionality in an easier-to-use form and
added support for Archlinux.

Find this module with ``find_package(cmakeme)``

#]=======================================================================]

set(cmakeme_pack_dir ${CMAKE_CURRENT_LIST_DIR}/cpack)


#[=======================================================================[.rst:
Commands
^^^^^^^^

.. command:: cmakeme_package

The ``cmakeme_package`` function generates binary packages from a cmake installation. 
The packages are built as a a result of the `package` target or running `cpack`
Generates tar.gz, .zip, .deb, and archlinux packages.

.. code-block:: cmake 

    cmakeme_package(EMAIL email 
        [ARCH_64 | ARCH_ANY ]
        [DEBIAN_DEPENDS d1...]
        [DEBIAN_RECOMMENDS r1 ...]
        [ARCHLINUX_DEPENDS a1...]
        [ARCHLINUX_RECOMMENDS a1...])

``EMAIL email`` 
The email address of the maintainer

``ARCH_64 | ARCH_ANY``
Platform for the package either x64 Linux or platform-indepedent (e.g., source only package)

``DEBIAN_DEPENDS`` 
Dependencies for the debian package

``DEBIAN_RECOMMENDS`` 
Optional dependencies for debian package

``ARCHLINUX_DEPENDS`` 
Dependencies for the archlinux package

``ARCHLINUX_RECOMMENDS`` 
Optional dependencies for arch linux
#]=======================================================================]
function(cmakeme_package)
  cmake_parse_arguments(
    "CMAKEME"
    "ARCH_64;ARCH_ANY"
    "EMAIL"
    "DEBIAN_DEPENDS;DEBIAN_RECOMMENDS;ARCHLINUX_DEPENDS;ARCHLINUX_RECOMMENDS"
    ${ARGN}
    )
  set(CPACK_GENERATOR "TGZ;ZIP;DEB;External")

  if(CMAKEME_ARCH_ANY)
    set(CPACK_SYSTEM_NAME "any")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
    set(CMAKEME_PKGBUILD_ARCH "any")
  else()
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CMAKEME_PKGBUILD_ARCH "x86_64")
  endif()

  set(CPACK_PACKAGE_CONTACT "${CMAKEME_EMAIL}")
  set(CPACK_DEBIAN_PACKAGE_DEPENDS ${CMAKEME_DEBIAN_DEPENDS})
  set(CPACK_DEBIAN_PACKAGE_RECOMMENDS ${CMAKEME_DEBIAN_RECOMMENDS})

  # make archlinux dependency lists suitable for insertion into the pkgbuild,
  # Where they must be elements of a bash array
  string(REPLACE ";" " " CMAKEME_ARCHLINUX_DEPENDS "${CMAKEME_ARCHLINUX_DEPENDS}")
  set(CMAKEME_PKGBUILD_DEPENDS ${CMAKEME_ARCHLINUX_DEPENDS})
  string(REPLACE ";" " " CMAKEME_ARCHLINUX_RECOMMENDS "${CMAKEME_ARCHLINUX_RECOMMENDS}")
  set(CMAKEME_PKGBUILD_RECOMMENDS ${CMAKEME_ARCHLINUX_RECOMMENDS})

  # The external target builds the archlinux package
  set(CPACK_EXTERNAL_PACKAGE_SCRIPT "${cmakeme_pack_dir}/cmakeme_pkgbuild.cmake")
  configure_file(${cmakeme_pack_dir}/PKGBUILD.in ${CMAKE_BINARY_DIR}/pkgbuild/PKGBUILD @ONLY)
  include(CPack)
endfunction()
