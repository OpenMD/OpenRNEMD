### Lower Level CMake Script for OpenRNEMD ###
cmake_minimum_required(VERSION 3.12.0)
project(UnitTesting VERSION 0.1.0)


### Unit Tests ###
if (rnemd_build_tests)
  OpenRNEMDNewTest(TESTNAME AllRNEMD)
endif()
