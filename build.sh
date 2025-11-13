#!/bin/bash

# Install Flutter if not exists
if [ ! -d "/vercel/.flutter" ]; then
  git clone https://github.com/flutter/flutter.git /vercel/.flutter
  export PATH="/vercel/.flutter/bin:$PATH"
  flutter doctor
fi

# Set Flutter path
export PATH="/vercel/.flutter/bin:$PATH"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build web
flutter build web --release