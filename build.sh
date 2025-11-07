#!/bin/bash

# To make this script executable, run:
#   chmod +x ci.sh

# Exit immediately if any command fails
set -e

# Create build directory if it doesn't exist
mkdir -p build

# Change into build directory
cd build

# Run CMake configuration
cmake ..

# Build the project
cmake --build .

# Run tests
ctest --output-on-failure