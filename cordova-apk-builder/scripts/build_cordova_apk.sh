#!/bin/bash

# Cordova APK Build Script
# This script builds a debug APK from a Cordova project

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Cordova APK Builder ===${NC}\n"

# Check if we're in a Cordova project
if [ ! -f "config.xml" ]; then
    echo -e "${RED}Error: config.xml not found. Are you in a Cordova project directory?${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found Cordova project"

# Check if cordova is installed
if ! command -v cordova &> /dev/null; then
    echo -e "${RED}Error: Cordova is not installed. Install it with: npm install -g cordova${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Cordova is installed ($(cordova --version))"

# Check if Android platform is added
if [ ! -d "platforms/android" ]; then
    echo -e "${YELLOW}Android platform not found. Adding it...${NC}"
    cordova platform add android
    echo -e "${GREEN}✓${NC} Android platform added"
else
    echo -e "${GREEN}✓${NC} Android platform exists"
fi

# Clean previous builds (optional but recommended)
echo -e "\n${YELLOW}Cleaning previous builds...${NC}"
cordova clean android

# Build debug APK
echo -e "\n${YELLOW}Building debug APK...${NC}"
cordova build android --debug

# Find and display APK location
APK_PATH=$(find platforms/android/app/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -n 1)

if [ -z "$APK_PATH" ]; then
    echo -e "${RED}Error: APK not found. Build may have failed.${NC}"
    exit 1
fi

echo -e "\n${GREEN}✓ Build successful!${NC}"
echo -e "APK location: ${GREEN}$APK_PATH${NC}"
echo -e "APK size: $(du -h "$APK_PATH" | cut -f1)"

# Check if device/emulator is connected
if adb devices | grep -q "device$"; then
    echo -e "\n${YELLOW}Device/emulator detected. To install, run:${NC}"
    echo -e "  adb install -r \"$APK_PATH\""
fi

echo -e "\n${GREEN}Done!${NC}"
