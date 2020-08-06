set(cmakeme_pack_dir ${CMAKE_CURRENT_LIST_DIR})


# Generate binary packages from a cmake installation. The packages
# are built as a a result of the `package` target or running `cpack`
# Generates tar.gz, .zip, .deb, and archlinux packages
# cmakeme_package(EMAIL email [ARCH_64 | ARCH_ANY ] [DEBIAN_DEPENDS d1...] [DEBIAN_RECOMMENDS r1 ...] [ARCHLINUX_DEPENDS a1...] [ARCHLINUX_RECOMMENDS a1...]
#  EMAIL - email address of the maintainer
#  ARCH_64 | ARCH_ANY - platform: either x64 Linux or platform-indepedent
#  DEBIAN_DEPENDS - dependencies for the debian package
#  DEBIAN_RECOMMENDS - Optional dependencies for debain package
#  ARCHLINUX_DEPENDS - Dependencies for archlinux
#  ARCHLINUX_RECOMMENDS - optional dependencies for arch linux
function(cmakeme_package)
  cmake_parse_arguments(
    "CMAKEME"
    "ARCH_64;ARCH_ANY"
    "EMAIL"
    "DEBIAN_DEPENDS;DEBIAN_RECOMMENDS;ARCHLINUX_DEPENDS;ARCHLINUX_RECOMMENDS"
    ${ARGN}
    )
  set(CPACK_GENERATOR "TGZ;ZIP;DEB;External")
  if(ARCH_ANY)
    set(CPACK_SYSTEM_NAME "Linux")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
    set(CMAKEME_PKGBUILD_ARCH "any")
  else()
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CMAKEME_PKGBUILD_ARCH "x86_64")
  endif()

  set(CPACK_PACKAGE_CONTACT ${CMAKEME_EMAIL})
  set(CPACK_DEBIAN_PACKAGE_DEPENDS ${CMAKEME_DEBIAN_DEPENDS})
  set(CPACK_DEBIAN_PACKAGE_RECOMMENDS ${CMAKEME_DEBIAN_RECOMMENDS})

  set(CMAKEME_PKGBUILD_DEPENDS ${CMAKEME_ARCHLINUX_DEPENDS})
  set(CMAKEME_PKGBUILD_RECOMMENDS ${CMAKEME_ARCHLINUX_RECOMMENDS})

  # The external target builds the archlinux package
  set(CPACK_EXTERNAL_PACKAGE_SCRIPT "${cmakemepack_dir}/cmakeme_pkgbuild.cmake")
  include(CPack)
  configure_file(${cmakemepack_dir}/PKGBUILD.in ${CPACK_PACKAGE_DIRECTORY}/pkgbuild/PKGBUILD @ONLY)
endfunction()
