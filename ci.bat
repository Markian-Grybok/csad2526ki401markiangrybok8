@echo off

:: Create a build directory if it doesn't exist
if not exist build mkdir build

:: Navigate to the build directory
cd build

:: Configure the project with CMake
cmake ..
if errorlevel 1 goto :error

:: Build the project
cmake --build .
if errorlevel 1 goto :error

:: Run tests with CTest, specifying Debug configuration
ctest -C Debug --output-on-failure
if errorlevel 1 goto :error

:: Exit successfully
echo Build and tests completed successfully.
goto :end

:error
echo An error occurred during the build or test process.
exit /b 1

:end
exit /b 0