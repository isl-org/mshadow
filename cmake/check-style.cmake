# ******************************************************************************
# Reference:
# https://github.com/NervanaSystems/ngraph/blob/master/cmake/Modules/style_check.cmake
#
# Copyright 2017-2019 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ******************************************************************************

# Try to locate "clang-format-5.0" and then "clang-format"
find_program(CLANG_FORMAT clang-format-5.0 PATHS ENV PATH)
if (NOT CLANG_FORMAT)
    find_program(CLANG_FORMAT clang-format PATHS ENV PATH)
endif()
if (CLANG_FORMAT)
    message(STATUS "clang-format found at: ${CLANG_FORMAT}")
    execute_process(COMMAND ${CLANG_FORMAT} --version)
else()
    message(FATAL_ERROR "clang-format not found, style not available")
endif()

macro(style_check_file_cpp FILE)
    execute_process(
        COMMAND ${CLANG_FORMAT} -style=file -output-replacements-xml ${FILE}
        OUTPUT_VARIABLE STYLE_CHECK_RESULT
    )
    if("${STYLE_CHECK_RESULT}" MATCHES ".*<replacement .*")
        message(STATUS "Style error: ${FILE}")
        list(APPEND ERROR_LIST_CPP ${FILE})
    endif()
endmacro()

set(DIRECTORIES_OF_INTEREST_CPP
    mshadow
    test
)

message(STATUS "C++ check-style...")
foreach(DIRECTORY ${DIRECTORIES_OF_INTEREST_CPP})
    set(CPP_GLOB "${PROJECT_SOURCE_DIR}/${DIRECTORY}/*.cpp")
    set(CC_GLOB "${PROJECT_SOURCE_DIR}/${DIRECTORY}/*.cc")
    set(H_GLOB "${PROJECT_SOURCE_DIR}/${DIRECTORY}/*.h")
    set(CU_GLOB "${PROJECT_SOURCE_DIR}/${DIRECTORY}/*.cu")
    set(CUH_GLOB "${PROJECT_SOURCE_DIR}/${DIRECTORY}/*.cuh")
    file(GLOB_RECURSE FILES ${CPP_GLOB} ${CC_GLOB} ${H_GLOB} ${CU_GLOB} ${CUH_GLOB})
    foreach(FILE ${FILES})
        style_check_file_cpp(${FILE})
    endforeach(FILE)
endforeach(DIRECTORY)
if(ERROR_LIST_CPP)
    message(FATAL_ERROR "Style errors")
endif()
message(STATUS "C++ check-style done")
