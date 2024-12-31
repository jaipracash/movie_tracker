#!/bin/bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter build for web
flutter doctor
flutter clean
flutter build web

# Move build output to appropriate location
mv build/web/* /opt/buildhome/clone/public/
