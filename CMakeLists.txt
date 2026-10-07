cmake_minimum_required(VERSION 3.16)
project(elmish_clay VERSION 0.1.0 LANGUAGES C)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_library(elmish_clay SHARED src/elmish_clay.c third_party/clay/clay.h)
target_include_directories(elmish_clay
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  PRIVATE
    third_party/clay)
target_compile_definitions(elmish_clay PRIVATE ECL_BUILD)
set_target_properties(elmish_clay PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION 0
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN YES)
if(UNIX AND NOT APPLE)
  target_link_libraries(elmish_clay PRIVATE m)
endif()
add_executable(elmish_clay_smoke tests/smoke.c)
target_link_libraries(elmish_clay_smoke PRIVATE elmish_clay)
enable_testing()
add_test(NAME elmish_clay_smoke COMMAND elmish_clay_smoke)

install(TARGETS elmish_clay
  EXPORT elmish_clayTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES include/elmish_clay.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT elmish_clayTargets
  FILE elmish_clayTargets.cmake
  NAMESPACE elmish_clay::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/elmish_clay)
configure_package_config_file(
  cmake/elmish_clayConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/elmish_clayConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/elmish_clay)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/elmish_clayConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/elmish_clayConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/elmish_clayConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/elmish_clay)
