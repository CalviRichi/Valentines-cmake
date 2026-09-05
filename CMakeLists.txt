cmake_minimum_required(VERSION 3.20)
project(Game LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---------------------------------------------------------------------------
# Dependencies — all fetched from source via CMake, so this file works
# identically on macOS, Linux, and Windows/MSVC. No prebuilt binaries needed.
# ---------------------------------------------------------------------------

include(FetchContent)

# --- GLFW ---
FetchContent_Declare(
    glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
    GIT_TAG        3.4
    GIT_SHALLOW    TRUE
)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(glfw)

# --- SDL2 ---
FetchContent_Declare(
    SDL2
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG        release-2.30.9
    GIT_SHALLOW    TRUE
)
set(SDL_SHARED ON CACHE BOOL "" FORCE)
set(SDL_STATIC OFF CACHE BOOL "" FORCE)
set(SDL_TEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL2)

# --- SDL2_mixer ---
# Only WAV support is enabled by default (built into SDL2_mixer, no extra
# codec libraries needed). Flip these ON later if you need MP3/OGG/etc,
# but each one pulls in its own dependency and complicates the build.
FetchContent_Declare(
    SDL2_mixer
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_mixer.git
    GIT_TAG        release-2.8.0
    GIT_SHALLOW    TRUE
)
set(SDL2MIXER_VENDORED ON CACHE BOOL "" FORCE)
# SDL2_mixer's CMakeLists reads the *generic* BUILD_SHARED_LIBS variable
# (not an SDL2MIXER_-prefixed one) to decide shared vs static, and names its
# exported target accordingly (SDL2_mixer::SDL2_mixer vs ...-static).
set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
set(SDL2MIXER_MP3 OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_OGG OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_FLAC OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MOD OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MIDI OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_OPUS OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_WAVPACK OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL2_mixer)

find_package(OpenGL REQUIRED)

# ---------------------------------------------------------------------------
# Project layout
# ---------------------------------------------------------------------------

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(ASSETS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/assets)

# ---------------------------------------------------------------------------
# glad (vendored: glad.c at project root, headers in dependencies/include)
# ---------------------------------------------------------------------------

add_library(glad STATIC
    ${SRC_DIR}/glad.c
)
target_include_directories(glad PUBLIC
    ${SRC_DIR}/dependencies/include
)

# ---------------------------------------------------------------------------
# Main executable
# ---------------------------------------------------------------------------

add_executable(${PROJECT_NAME}
    ${SRC_DIR}/main.c
    ${SRC_DIR}/heart_object.c
    ${SRC_DIR}/map.c
    ${SRC_DIR}/player.c
    ${SRC_DIR}/render.c
    ${SRC_DIR}/sprite.c
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${SRC_DIR}
    ${SRC_DIR}/dependencies/include
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    ASSETS_DIR="${ASSETS_DIR}"
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    glad
    glfw
    SDL2::SDL2
    SDL2::SDL2main
    SDL2_mixer::SDL2_mixer
    OpenGL::GL
)

if(APPLE)
    target_compile_definitions(${PROJECT_NAME} PRIVATE GL_SILENCE_DEPRECATION)
endif()
