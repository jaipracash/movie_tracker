#!/bin/bash

# Add Flutter to PATH
export PATH="$PATH:$PWD/flutter/bin"

# Verify Flutter installation
flutter --version || {
  echo "Flutter is not installed or accessible. Aborting."
  exit 1
}

# Enable web support
flutter config --enable-web

# Build the Flutter web app
flutter build web
