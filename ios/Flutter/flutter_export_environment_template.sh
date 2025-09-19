#!/bin/sh
# This is a template for flutter_export_environment.sh
# Copy this file to flutter_export_environment.sh and update paths as needed

# Flutter root - update this path for your system
export "FLUTTER_ROOT=/path/to/flutter"

# Application path - update this path for your system  
export "FLUTTER_APPLICATION_PATH=/path/to/fresh_checkin_app"

# Build configuration
export "COCOAPODS_PARALLEL_CODE_SIGN=true"
export "FLUTTER_TARGET=lib/main.dart"
export "FLUTTER_BUILD_DIR=build"
export "FLUTTER_BUILD_NAME=1.0.0"
export "FLUTTER_BUILD_NUMBER=1"
export "EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386"
export "EXCLUDED_ARCHS[sdk=iphoneos*]=armv7"
export "DART_OBFUSCATION=false"
export "TRACK_WIDGET_CREATION=true"
export "TREE_SHAKE_ICONS=false"
export "PACKAGE_CONFIG=.dart_tool/package_config.json"