@echo off
setlocal enabledelayedexpansion

:: Інформація про збірку
echo [BUILD] Starting CI build process
echo [TIME] %date% %time%

:: Конфігурація
set "BUILD_DIR=build"
set "CONFIG=Release"

:: Перевірка CMake
cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] CMake is not installed or not in PATH
    exit /b 1
)

:: Очищення попередньої збірки
if exist "%BUILD_DIR%" (
    echo [CLEAN] Removing old build directory
    rmdir /s /q "%BUILD_DIR%"
)

:: Створення директорії збірки
mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

:: Конфігурація проекту
echo [CONFIG] Configuring project...
cmake .. -DCMAKE_BUILD_TYPE=%CONFIG%
if !errorlevel! neq 0 goto :error

:: Збірка проекту
echo [BUILD] Building project...
cmake --build . --config %CONFIG% --parallel 2
if !errorlevel! neq 0 goto :error

:: Запуск тестів
echo [TEST] Running tests...
ctest -C %CONFIG% --output-on-failure
set TEST_EXITCODE=!errorlevel!

:: Звіт про результати
echo.
if !TEST_EXITCODE! equ 0 (
    echo ✅ BUILD SUCCESSFUL
    echo 📍 Build directory: %CD%
) else (
    echo ❌ SOME TESTS FAILED
)

:: Копіювання артефактів
if not exist "..\artifacts" mkdir "..\artifacts"
xcopy /Y /I "*.exe" "..\artifacts\" >nul 2>&1

echo [INFO] Build process completed
endlocal
exit /b %TEST_EXITCODE%

:error
echo [ERROR] Build process failed at step: %ERRORSTEP%
exit /b 1