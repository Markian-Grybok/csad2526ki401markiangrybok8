cmake_minimum_required(VERSION 3.16)
project(MathProject VERSION 1.0.0 LANGUAGES CXX)

# Основні налаштування
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Додаємо поточну директорію до шляхів пошуку заголовків
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Специфічні налаштування для Windows
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    add_compile_options(/W3)
else()
    add_compile_options(-Wall -Wextra)
endif()

# Підтримка тестування
include(CTest)
enable_testing()

# Завантаження Google Test
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.13.0
)

FetchContent_MakeAvailable(googletest)

# Основна бібліотека
add_library(math_operations 
    math_operations.cpp
    math_operations.h
)

# Додаємо шляхи для бібліотеки
target_include_directories(math_operations 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Головний виконуваний файл
add_executable(main_app main.cpp)
target_link_libraries(main_app PRIVATE math_operations)

# Тестовий виконуваний файл
add_executable(unit_tests tests/unit_tests.cpp)
target_link_libraries(unit_tests PRIVATE math_operations gtest gtest_main)

# Додаємо шляхи для тестів
target_include_directories(unit_tests 
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Реєстрація тестів
add_test(
    NAME MathUnitTests
    COMMAND unit_tests
)

# Додаткова ціль для швидкого запуску
add_custom_target(run-all
    COMMAND unit_tests
    DEPENDS unit_tests
    COMMENT "Building and running all tests"
)
