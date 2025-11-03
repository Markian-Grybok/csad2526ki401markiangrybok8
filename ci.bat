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

rem 3) Configure project with CMake
echo [CI] Configuring project with CMake...
cmake .. || (
    echo [CI] CMake configuration failed
    popd
    exit /b 1
)

rem 4) Build project (try Release first, fallback to default)
echo [CI] Building project (Release)...
cmake --build . --config Release || (
    echo [CI] Release build failed, trying default config...
    cmake --build . || (
        echo [CI] Build failed
        popd
        exit /b 1
    )
)

rem 5) Run tests via CTest (try Release config then default)
echo [CI] Running tests with CTest...
ctest --output-on-failure -C Release || ctest --output-on-failure || (
    echo [CI] Tests failed
    popd
    exit /b 1
)

rem Leave build dir
popd

rem 6) Normalize or copy produced executable to hello(.exe)
echo [CI] Locating produced executable...
set "EXE="
if exist build\Release\HelloWorld.exe set "EXE=build\Release\HelloWorld.exe"
if "%EXE%"=="" if exist build\HelloWorld.exe set "EXE=build\HelloWorld.exe"
if "%EXE%"=="" if exist build\Release\hello.exe set "EXE=build\Release\hello.exe"
if "%EXE%"=="" if exist build\hello.exe set "EXE=build\hello.exe"

if not "%EXE%"=="" (
    copy /Y "%EXE%" "hello.exe" >nul
    echo [CI] Copied "%EXE%" to "hello.exe"
) else (
    echo [CI] Warning: executable not found. Expected HelloWorld(.exe) or hello(.exe) in build/ or build/Release/
)

rem 7) Create a helper build.sh for Unix-like systems (if missing)
if not exist build.sh (
    echo [CI] Creating helper script build.sh...
    >build.sh echo #!/usr/bin/env bash
    >>build.sh echo set -e
    >>build.sh echo ""
    >>build.sh echo "mkdir -p build"
    >>build.sh echo "cd build"
    >>build.sh echo "cmake .."
    >>build.sh echo "cmake --build ."
    >>build.sh echo "ctest --output-on-failure"
)

rem 8) Ensure execution permission on build.sh (try bash then git)
where bash >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [CI] Setting executable bit on build.sh using bash...
    bash -lc "chmod +x build.sh" || echo [CI] chmod via bash failed
) else (
    echo [CI] bash not found, trying git update-index to set exec bit...
    git update-index --add --chmod=+x build.sh >nul 2>&1 || echo [CI] Could not set exec bit with git (git missing or unsupported)
)

rem 9) Stage and commit the created/modified scripts (if git available)
git --version >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [CI] Staging and committing changes (build.sh, ci.bat)...
    git add build.sh ci.bat >nul 2>&1
    git commit -m "ci: add local CI build scripts" >nul 2>&1 || echo [CI] Nothing to commit or commit failed
) else (
    echo [CI] git not found; skipping commit
)

echo [CI] Local CI script finished successfully.
endlocal
exit /b 0
