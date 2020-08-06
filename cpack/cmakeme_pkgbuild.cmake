# CPack script for building an archlinux package
find_program(MAKEPKG makepkg)
if(MAKEPKG STREQUAL makepkg-NOTFOUND)
  message(STATUS "Could not find makepkg, skipping archlinux package")
  return()
endif()

file(COPY ${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.tar.gz
  DESTINATION ${CPACK_PACKAGE_DIRECTORY}/pkgbuild)

set(ENV{PKGEXT} ".pkg.tar.zst")
execute_process(COMMAND ${MAKEPKG}
  WORKING_DIRECTORY ${CPACK_PACKAGE_DIRECTORY}/pkgbuild)

file(GLOB pkgfiles ${CPACK_PACKAGE_DIRECTORY}/pkgbuild/*.pkg.tar.zst)
file(COPY ${pkgfiles} DESTINATION ${CPACK_PACKAGE_DIRECTORY})
