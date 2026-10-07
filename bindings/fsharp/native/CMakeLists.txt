cmake_minimum_required(VERSION 3.16)
project(eclaire_native LANGUAGES C)
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
add_library(eclaire ${ECLAIRE_LIBRARY_TYPE} src/eclaire.c)
target_include_directories(eclaire PRIVATE include third_party/clay)
target_compile_definitions(eclaire PRIVATE ECLAIRE_BUILD)
if(UNIX AND NOT APPLE)
  target_link_libraries(eclaire PRIVATE m)
endif()
set_target_properties(eclaire PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out")

foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
  set_target_properties(eclaire PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/out"
    LIBRARY_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/out"
    RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/out")
endforeach()
