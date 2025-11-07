@echo off
rem CI local build script for Windows (ci.bat / ci.cmd)
rem Usage: run without parameters from repository root

setlocal

echo [CI] Starting local CI build...

rem 1) Create build directory if needed
if not exist build (
    mkdir build
) else (
    echo [CI] build directory already exists
)

rem 2) Enter build directory
pushd build || (echo [CI] Failed to enter build directory & exit /b 1)

rem 3) Configure project with CMake using Visual Studio generator
echo [CI] Configuring project with CMake...
cmake -G "Visual Studio 17 2022" -A x64 .. || (
    echo [CI] Trying alternative generator...
    cmake -G "Visual Studio 16 2019" -A x64 .. || (
        echo [CI] Trying MinGW Makefiles...
        cmake -G "MinGW Makefiles" .. || (
            echo [CI] CMake configuration failed with all generators
            popd
            exit /b 1
        )
    )
)

rem 4) Build project (Release configuration)
echo [CI] Building project (Release)...
cmake --build . --config Release || (
    echo [CI] Release build failed, trying Debug config...
    cmake --build . --config Debug || (
        echo [CI] Build failed
        popd
        exit /b 1
    )
)

rem 5) Run tests via CTest
echo [CI] Running tests with CTest...
ctest --output-on-failure --verbose -C Release || (
    echo [CI] Trying tests in Debug configuration...
    ctest --output-on-failure --verbose -C Debug || (
        echo [CI] Tests failed
        popd
        exit /b 1
    )
)

rem Leave build dir
popd

rem 6) Locate and copy produced executable
echo [CI] Locating produced executable...
set "EXE="
if exist build\Release\HelloWorld.exe set "EXE=build\Release\HelloWorld.exe"
if "%EXE%"=="" if exist build\Debug\HelloWorld.exe set "EXE=build\Debug\HelloWorld.exe"
if "%EXE%"=="" if exist build\HelloWorld.exe set "EXE=build\HelloWorld.exe"

if not "%EXE%"=="" (
    copy /Y "%EXE%" "hello.exe" >nul
    echo [CI] Copied "%EXE%" to "hello.exe"
) else (
    echo [CI] Warning: executable not found
)

echo [CI] Local CI script finished successfully.
endlocal
exit /b 0