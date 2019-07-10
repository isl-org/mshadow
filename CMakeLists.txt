cmake_minimum_required(VERSION 3.10)
project (gpu_tensor LANGUAGES CXX C)
include(CheckCXXCompilerFlag)

project(mshadow C CXX)

# GoogleTest lib
set(googletest_INCLUDE_DIRS
    googletest/googletest/include/
    googletest/googletest/
    googletest/googlemock/include/
    googletest/googlemock/
)
set(googletest_SOURCE
    googletest/googletest/src/gtest-all.cc
    googletest/googlemock/src/gmock-all.cc
)
include_directories(${googletest_INCLUDE_DIRS})
add_library(googletest STATIC ${googletest_SOURCE})
target_link_libraries(googletest pthread)

# Mshadow
set(USE_BLAS "Blas")
set(USE_CUDA 1)
include(cmake/mshadow.cmake)

# Cuda
# TODO: make optional
find_package(CUDA 8.0)
if (CUDA_FOUND)
    message(STATUS "CUDA found")
else()
    message(FALTAL_ERROR "CUDA not found")
endif()

# Unit test executable
set (UNIT_TEST_SRC
    test/main.cc
    test/guide_basic_stream.cu
    test/guide_basic.cc
)
cuda_add_executable(unit_test ${UNIT_TEST_SRC})
target_include_directories(unit_test PUBLIC
    ${CUDA_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
)
target_link_libraries(unit_test
    googletest
    blas # TODO: modify mshadow's CMake to include this
    ${mshadow_LINKER_LIBS}
)

# `make check-style` errors if styling is not compliant
add_custom_target(check-style
    COMMAND ${CMAKE_COMMAND}
    -DPROJECT_SOURCE_DIR="${PROJECT_SOURCE_DIR}"
    -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/check-style.cmake
)

# `make apply-style` runs clang-format to format all source code
add_custom_target(apply-style
    COMMAND ${CMAKE_COMMAND}
    -DPROJECT_SOURCE_DIR="${PROJECT_SOURCE_DIR}"
    -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/apply-style.cmake
)
