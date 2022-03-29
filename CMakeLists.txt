# CMakeの最小バージョンの指定
cmake_minimum_required(VERSION 3.13)

# プロジェクトの作成
project(sol2_practice)

# C++17を使用する
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
find_package(Threads REQUIRED)

# compile_commands.jsonを生成するようにする
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "generate compile_commands.json" FORCE)

# sol2の追加
include(cmake/sol2.cmake)

# アプリの作成
file(GLOB_RECURSE ALL_CPP_FILES "${PROJECT_SOURCE_DIR}/src/*.cpp")
add_executable(main main.cpp "${ALL_CPP_FILES}")
target_include_directories(main PUBLIC "${PROJECT_SOURCE_DIR}/include")

# sol2をライブラリとして追加
target_link_libraries(main PRIVATE ${sol2_lib})
