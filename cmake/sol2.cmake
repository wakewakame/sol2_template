# CMakeの最小バージョンの指定
cmake_minimum_required(VERSION 3.13)

# LuaJITの追加
include(cmake/LuaJIT.cmake)

include(ExternalProject)

# sol2の追加
set(SOL2_VERSION "v3.2.3")
string(TOLOWER "sol2" SOL2_TARGET_NAME)
set(SOL2_BUILD_TOPLEVEL "${CMAKE_BINARY_DIR}/3rdparty/sol2_${SOL2_VERSION}")
set(SOL2_INCLUDE_DIR "${SOL2_BUILD_TOPLEVEL}/include")
ExternalProject_Add(SOL2
	GIT_REPOSITORY https://github.com/ThePhD/sol2.git
	GIT_TAG "${SOL2_VERSION}"
	GIT_SHALLOW TRUE
	UPDATE_DISCONNECTED YES
	PREFIX "${SOL2_BUILD_TOPLEVEL}"
	SOURCE_DIR "${SOL2_BUILD_TOPLEVEL}"
	DOWNLOAD_DIR "${SOL2_BUILD_TOPLEVEL}"
	TMP_DIR "${SOL2_BUILD_TOPLEVEL}-tmp"
	STAMP_DIR "${SOL2_BUILD_TOPLEVEL}-stamp"
	BINARY_DIR "${SOL2_BUILD_TOPLEVEL}-build"
	BUILD_COMMAND ""
	INSTALL_COMMAND "")

# sol2 Library
set(sol2_lib sol2_${SOL2_VERSION})
add_library(${sol2_lib} INTERFACE)
add_dependencies(${sol2_lib} SOL2)
target_include_directories(${sol2_lib} INTERFACE "${SOL2_INCLUDE_DIR}")
target_link_libraries(${sol2_lib} INTERFACE ${luajit_lib})
