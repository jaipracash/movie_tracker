#!/bin/sh

# Check if Flutter is already cloned, if not, clone it
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --branch stable --depth 1 flutter
fi

# Set Flutter environment variable
export PATH="$PATH:`pwd`/flutter/bin"

# Ensure Flutter dependencies are installed
flutter doctor

# Build the Flutter web application
flutter build web
