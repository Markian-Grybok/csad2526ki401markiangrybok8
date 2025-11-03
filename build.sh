#!/usr/bin/env bash
set -e

# Helper script for Unix-like systems to run the same local CI steps.
# Usage: ./build.sh (must be executable)

mkdir -p build
cd build

# Configure + build
cmake ..
cmake --build .

# Run tests
ctest --output-on-failure
