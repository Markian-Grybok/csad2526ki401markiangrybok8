#!/usr/bin/env bash
set -e

echo "[BUILD] Starting build process..."

# Create build directory
mkdir -p build
cd build

echo "[BUILD] Configuring project with CMake..."
cmake ..

echo "[BUILD] Building project..."
cmake --build .

echo "[BUILD] Build completed. Contents of build directory:"
ls -la

echo "[BUILD] Running tests with CTest..."
ctest --output-on-failure --verbose

echo "[BUILD] Build and test process completed successfully!"