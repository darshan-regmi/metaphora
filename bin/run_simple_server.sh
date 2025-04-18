#!/bin/bash

# Make sure Dart is installed
if ! command -v dart &> /dev/null; then
    echo "Dart is not installed. Please install Dart first."
    echo "For Mac: brew install dart"
    echo "For Linux: sudo apt install dart"
    echo "For Windows: choco install dart-sdk"
    exit 1
fi

# Run the server
echo "Starting Poetry Sharing App simple server on http://localhost:8080..."
dart run bin/simple_server.dart
