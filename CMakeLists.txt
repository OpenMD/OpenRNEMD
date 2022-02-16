### Top Level CMake Script for OpenRNEMD ###
cmake_minimum_required(VERSION 3.12.0)
project(OpenRNEMD VERSION 0.1.0)


### Options ###
option(rnemd_build_all       "Builds all libraries, unit tests, and code samples." OFF)
option(rnemd_build_tests     "Builds all libraries and unit tests." OFF)
option(rnemd_build_samples   "Builds all libraries and code samples." OFF)
option(rnemd_configure_docs  "Builds specified libraries while configuring the Doxygen file for documentation generation." OFF)
option(rnemd_enable_coverage "Builds all libraries, unit tests, and enables coverage options." OFF)
option(rnemd_format_codebase "Builds specified libraries while also formatting the code." OFF)

if (rnemd_format_codebase AND NOT WIN32)
    find_program(formatter clang-format HINTS /opt/local/libexec/llvm-11/bin/)

    if (NOT formatter_NOTFOUND)
        message(STATUS "Formatting OpenRNEMD")

        ## Run clang-format on all code except the files passed as arguments with the '-i' flag ##
        execute_process(COMMAND bash cmake/scripts/format-codebase.sh
                                        -f ${formatter}
                        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                        OUTPUT_QUIET)
    endif()
endif()

if (rnemd_enable_coverage)
    set(rnemd_build_tests ON)
    set(CMAKE_BUILD_TYPE "Debug")
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} --coverage)
endif()

if (rnemd_configure_docs)
    configure_file(${PROJECT_SOURCE_DIR}/docs/Doxyfile.in ${PROJECT_BINARY_DIR}/Doxyfile)
endif()

if (rnemd_build_all)
    set(rnemd_build_tests ON)
    set(rnemd_build_samples ON)
endif()


### Compilation Options ###
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

if (WIN32)
    add_compile_options(/MD /WX)
else()
    add_compile_options(-pedantic-errors -Wall -Werror -Wextra)
endif()

if (CMAKE_COMPILER_IS_GNUCXX)
    add_compile_options(-Wno-psabi)
endif()

### Functions ###
include(cmake/utility-functions.cmake)

### Files / Directories ###
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
    CACHE PATH "Single directory for all executables.")

SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib
    CACHE PATH "Single directory for all static libraries.")


### Libraries / Executables ###
include_directories(rnemd/include)

if (rnemd_build_all)
    set(rnemd_build_tests ON)
    set(rnemd_build_samples ON)
endif()


### Libraries / Executables ###
set(LIBRARIES rnemd/include/rnemd)


### Installation ###
install(DIRECTORY ${LIBRARIES}
        DESTINATION include)


### Unit Testing ###
if (rnemd_build_tests)
    find_package(GTest)
    find_package(Threads)

    if (NOT ${GTest_FOUND})
        ## If googletest isn't installed or can't be found, download it from github ##
        OpenRNEMDExternalDownload(PROJECT googletest
                                  REPOSITORY "https://github.com/google/googletest.git")

        set(GTEST_LIBRARIES gtest)
        set(GTEST_INCLUDE_DIRS "${gtest_SOURCE_DIR}/include")
    endif()

    include_directories(${GTEST_INCLUDE_DIRS})

    include(CTest)
    include(GoogleTest)

    enable_testing()

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin/tests)

    add_subdirectory(cmake/Testing ${PROJECT_BINARY_DIR}/Testing)

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
endif()
