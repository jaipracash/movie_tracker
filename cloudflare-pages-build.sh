#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git --branch stable --depth 1 flutter
export PATH="$PWD/flutter/bin:$PATH"

# Ensure Flutter is in the path
flutter doctor

# Build the web app
flutter build web
