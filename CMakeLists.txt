cmake_minimum_required(VERSION 3.16)
project(eclaire VERSION 0.1.1 LANGUAGES C)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/eclaire.toml" ECLAIRE_CLAY_HASH_LINE REGEX "^clay_header_sha256 = ")
string(REGEX REPLACE "^clay_header_sha256 = \"([0-9a-f]+)\"$" "\\1" ECLAIRE_EXPECTED_CLAY_HASH "${ECLAIRE_CLAY_HASH_LINE}")
file(SHA256 "${CMAKE_CURRENT_SOURCE_DIR}/third_party/clay/clay.h" ECLAIRE_ACTUAL_CLAY_HASH)
if(NOT ECLAIRE_ACTUAL_CLAY_HASH STREQUAL ECLAIRE_EXPECTED_CLAY_HASH)
  message(FATAL_ERROR "Vendored Clay header hash does not match eclaire.toml")
endif()
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(ECLAIRE_LIBRARY_TYPE SHARED CACHE STRING "Native library type (SHARED or STATIC)")
set_property(CACHE ECLAIRE_LIBRARY_TYPE PROPERTY STRINGS SHARED STATIC)
add_library(eclaire ${ECLAIRE_LIBRARY_TYPE} src/eclaire.c third_party/clay/clay.h)
target_include_directories(eclaire
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  PRIVATE
    third_party/clay)
target_compile_definitions(eclaire PRIVATE ECLAIRE_BUILD)
set_target_properties(eclaire PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION 0
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN YES)
if(UNIX AND NOT APPLE)
  target_link_libraries(eclaire PRIVATE m)
endif()
option(ECLAIRE_BUILD_TESTS "Build native smoke tests" ON)
if(ECLAIRE_BUILD_TESTS)
  add_executable(eclaire_smoke tests/smoke.c)
  target_link_libraries(eclaire_smoke PRIVATE eclaire)
  enable_testing()
  add_test(NAME eclaire_smoke COMMAND eclaire_smoke)
endif()

install(TARGETS eclaire
  EXPORT eclaireTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES include/eclaire.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT eclaireTargets
  FILE eclaireTargets.cmake
  NAMESPACE eclaire::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/eclaire)
configure_package_config_file(
  cmake/eclaireConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/eclaireConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/eclaire)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/eclaireConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/eclaireConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/eclaireConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/eclaire)
