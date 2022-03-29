# The major design pattern of this program was abstracted from sol3.
# Here is the original copyright notice for sol3:




# # # # sol3
# The MIT License (MIT)
# 
# Copyright (c) 2013-2020 Rapptz, ThePhD, and contributors
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# import necessary standard modules
include(ExternalProject)

# 3-digit with optional beta1/beta2/beta3 (or whatever): probably okay?
set(LUA_JIT_VERSION "v2.0.5")

set(LUA_BUILD_TOPLEVEL "${CMAKE_BINARY_DIR}/3rdparty/luajit_${LUA_JIT_VERSION}")
set(LUA_JIT_SOURCE_DIR "${LUA_BUILD_TOPLEVEL}/src")

set(LUA_BUILD_LIBNAME "luajit")
set(LUA_JIT_LIB_FILENAME "${CMAKE_STATIC_LIBRARY_PREFIX}${LUA_BUILD_LIBNAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")

# # # Do the build
if (MSVC)
	# Visual C++ is predicated off running msvcbuild.bat
	# which requires a Visual Studio Command Prompt
	# make sure to find the right one
	find_program(VCVARS_ALL_BAT NAMES "vcvarsall.bat")
	if (VCVARS_ALL_BAT MATCHES "VCVARS_ALL_BAT-NOTFOUND")
		MESSAGE(FATAL_ERROR "Cannot find 'vcvarsall.bat' file or similar needed to build LuaJIT ${LUA_VERSION} on Windows")
	endif()
	if (CMAKE_SIZEOF_VOID_P LESS_EQUAL 4)
		set(LUA_JIT_MAKE_COMMAND "${VCVARS_ALL_BAT}" x86)
	else()
		set(LUA_JIT_MAKE_COMMAND "${VCVARS_ALL_BAT}" x64)
	endif()
	set(LUA_JIT_MAKE_COMMAND ${LUA_JIT_MAKE_COMMAND} && cd src && msvcbuild.bat)
	if (CMAKE_BUILD_TYPE MATCHES "Debug")
		set(LUA_JIT_MAKE_COMMAND ${LUA_JIT_MAKE_COMMAND} debug)
	endif()

	set(LUA_JIT_MAKE_COMMAND ${LUA_JIT_MAKE_COMMAND} static)
	set(LUA_JIT_PREBUILT_LIB "lua51.lib")
else ()
	# get the make command we need for this system
	find_program(MAKE_PROGRAM NAMES make mingw32-make mingw64-make)
	if (MAKE_PROGRAM MATCHES "MAKE_PROGRAM-NOTFOUND")
		MESSAGE(FATAL_ERROR "Cannot find 'make' program or similar needed to build LuaJIT ${LUA_VERSION} (perhaps place it in the PATH environment variable if it is not already?)")
	endif()

	# we can simply reuse the makefile here
	# so define it as an external project and then just have the proper
	# build/install/test commands
	# make sure to apply -pagezero_size 10000 -image_base 100000000 (done later for XCode Targets)
	set(LUA_JIT_MAKE_BUILD_MODIFICATIONS "LUAJIT_A=${LUA_JIT_LIB_FILENAME}")
	list(APPEND LUA_JIT_MAKE_BUILD_MODIFICATIONS "BUILDMODE=static")
	if (IS_X86)
		list(APPEND LUA_JIT_MAKE_BUILD_MODIFICATIONS "CC=${CMAKE_C_COMPILER} -m32")
		list(APPEND LUA_JIT_MAKE_BUILD_MODIFICATIONS "LDFLAGS=-m32")
	endif()
	if (WIN32)
		list(APPEND LUA_JIT_MAKE_BUILD_MODIFICATIONS "HOST_SYS=Windows" "TARGET_SYS=Windows" "TARGET_AR=ar rcus")
	endif()

	set(LUA_JIT_MAKE_COMMAND "${MAKE_PROGRAM}" ${LUA_JIT_MAKE_BUILD_MODIFICATIONS})
	set(LUA_JIT_PREBUILT_LIB ${LUA_JIT_LIB_FILENAME})
endif()

ExternalProject_Add(LUA_JIT
	BUILD_IN_SOURCE TRUE
	BUILD_ALWAYS FALSE
	PREFIX "${LUA_BUILD_TOPLEVEL}"
	SOURCE_DIR "${LUA_BUILD_TOPLEVEL}"
	DOWNLOAD_DIR "${LUA_BUILD_TOPLEVEL}"
	TMP_DIR "${LUA_BUILD_TOPLEVEL}-tmp"
	STAMP_DIR "${LUA_BUILD_TOPLEVEL}-stamp"
	GIT_REPOSITORY https://github.com/LuaJIT/LuaJIT.git
	GIT_TAG "${LUA_JIT_VERSION}"
	GIT_SHALLOW TRUE
	CONFIGURE_COMMAND ""
	BUILD_COMMAND ${LUA_JIT_MAKE_COMMAND}
	INSTALL_COMMAND ""
	TEST_COMMAND "")

# Lua Library
set(luajit_lib luajit_lib_${LUA_JIT_VERSION})
add_library(${luajit_lib} INTERFACE)
add_dependencies(${luajit_lib} LUA_JIT)
target_include_directories(${luajit_lib} INTERFACE "${LUA_JIT_SOURCE_DIR}")
file(TO_CMAKE_PATH "${LUA_JIT_SOURCE_DIR}/${LUA_JIT_PREBUILT_LIB}" LUA_JIT_SOURCE_LUA_LIB)
target_link_directories(${luajit_lib} INTERFACE "${LUA_JIT_SOURCE_DIR}")
target_link_libraries(${luajit_lib} INTERFACE "${LUA_JIT_SOURCE_LUA_LIB}")
if (CMAKE_DL_LIBS)
	target_link_libraries(${luajit_lib} INTERFACE ${CMAKE_DL_LIBS})
endif()
