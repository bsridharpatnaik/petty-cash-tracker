#!/bin/bash

echo ''
echo "Building Flutter Web for $1 distribution"
echo ''

PROJECT_NAME=expense_tracker
PACK_NAME="${1}_${PROJECT_NAME}$(date +_%Y_%m_%d_%H_%M_%S).tar.gz"

echo ''
echo "Cleaning previous builds"
echo ''
flutter clean

echo ''
echo "Getting Flutter dependencies"
echo ''
flutter pub get

echo ''
echo "Calculating 60% of system RAM for Dart/Flutter optimization"
echo ''

# Detect OS
OS="$(uname -s)"

if [ "$OS" == "Darwin" ]; then
    total_ram=$(sysctl -n hw.memsize)
else
    total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    total_ram=$((total_ram * 1024))
fi

ram_60_percent=$((total_ram * 60 / 100))
ram_60_percent_mb=$((ram_60_percent / 1024 / 1024))

export DART_VM_OPTIONS="--old_gen_heap_size=${ram_60_percent_mb}"

echo "Flutter build web using approx ${ram_60_percent_mb} MB RAM"
flutter build web --release

echo ''
echo "Removing macOS extended attributes (if applicable)"
echo ''
if [ "$OS" == "Darwin" ]; then
    xattr -cr build/web
fi

echo ''
echo "Creating archive: $PACK_NAME"
echo ''
if [ "$OS" == "Darwin" ]; then
    tar --disable-copyfile --no-xattrs -cvzf "$PACK_NAME" -C build web
else
    tar -cvzf "$PACK_NAME" -C build web
fi

echo ''
echo "Build and archive complete: $PACK_NAME"
echo ''

# Open file explorer
if [ "$OS" == "Darwin" ]; then
    open .
else
    nautilus . &
fi
