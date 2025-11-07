cmake_minimum_required(VERSION 3.14)
project(HelloWorld LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Main executable
add_executable(HelloWorld main.cpp)

# Option to enable/disable building tests
option(BUILD_TESTS "Build unit tests" ON)

if(BUILD_TESTS)
    enable_testing()
    include(FetchContent)

    # Fetch GoogleTest
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/heads/main.zip
    )

    # Prevent GoogleTest from overriding our compiler options
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    # Simple test target using the existing unit_tests.cpp in tests/ folder
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/unit_tests.cpp")
        add_executable(unit_tests
            tests/unit_tests.cpp
            math_operations.cpp
        )
        target_include_directories(unit_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
        add_test(NAME BasicAddition COMMAND unit_tests)

        # Copy unit_tests to tests folder after build for easier running
        add_custom_command(TARGET unit_tests POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/tests/build
            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:unit_tests> ${CMAKE_CURRENT_SOURCE_DIR}/tests/build/
        )
    endif()

    # If you create a GoogleTest-based test file named gtest_math_tests.cpp, this target will be built and run.
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/gtest_math_tests.cpp")
        add_executable(gtest_math_tests
            gtest_math_tests.cpp
            math_operations.cpp
        )
        target_include_directories(gtest_math_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
        target_link_libraries(gtest_math_tests PRIVATE GTest::gtest_main)
        include(GoogleTest)
        gtest_discover_tests(gtest_math_tests)
    endif()
endif()