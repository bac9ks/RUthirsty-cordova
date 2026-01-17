#!/bin/bash

# Cordova Android Environment Check Script
# Verifies that all required tools are installed for Android development

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Cordova Android Environment Check ===${NC}\n"

ISSUES=0
WARNINGS=0

# Function to check command existence
check_command() {
    local cmd=$1
    local name=$2
    local install_hint=$3

    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: Not found"
        if [ -n "$install_hint" ]; then
            echo -e "  ${YELLOW}Install:${NC} $install_hint"
        fi
        ((ISSUES++))
        return 1
    fi
}

# Check Node.js
check_command "node" "Node.js" "Visit https://nodejs.org/"

# Check npm
check_command "npm" "npm" "Comes with Node.js"

# Check Cordova
check_command "cordova" "Cordova" "npm install -g cordova"

# Check Java (JDK)
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓${NC} Java: $JAVA_VERSION"

    # Check if it's JDK (not just JRE)
    if command -v javac &> /dev/null; then
        echo -e "${GREEN}✓${NC} Java Compiler (javac): Found"
    else
        echo -e "${YELLOW}⚠${NC} Java Compiler (javac): Not found (JRE only)"
        echo -e "  ${YELLOW}Install JDK:${NC} You need Java Development Kit, not just JRE"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} Java: Not found"
    echo -e "  ${YELLOW}Install:${NC} Install Java JDK 11 or later"
    ((ISSUES++))
fi

# Check Gradle
check_command "gradle" "Gradle" "Should be installed automatically by Cordova"

# Check Android SDK
echo
echo -e "${BLUE}Checking Android SDK...${NC}"

if [ -n "$ANDROID_HOME" ]; then
    echo -e "${GREEN}✓${NC} ANDROID_HOME: $ANDROID_HOME"

    # Check if Android SDK actually exists at that location
    if [ -d "$ANDROID_HOME" ]; then
        echo -e "${GREEN}✓${NC} Android SDK directory exists"

        # Check for important SDK components
        if [ -d "$ANDROID_HOME/platform-tools" ]; then
            echo -e "${GREEN}✓${NC} Platform tools found"
        else
            echo -e "${YELLOW}⚠${NC} Platform tools not found"
            ((WARNINGS++))
        fi

        if [ -d "$ANDROID_HOME/build-tools" ]; then
            echo -e "${GREEN}✓${NC} Build tools found"
        else
            echo -e "${YELLOW}⚠${NC} Build tools not found"
            ((WARNINGS++))
        fi

    else
        echo -e "${RED}✗${NC} ANDROID_HOME points to non-existent directory"
        ((ISSUES++))
    fi
else
    echo -e "${RED}✗${NC} ANDROID_HOME: Not set"
    echo -e "  ${YELLOW}Setup:${NC} Set ANDROID_HOME environment variable"
    ((ISSUES++))
fi

# Check adb (Android Debug Bridge)
check_command "adb" "Android Debug Bridge (adb)" "Install Android SDK Platform Tools"

# Check for connected devices
echo
echo -e "${BLUE}Checking for connected Android devices/emulators...${NC}"
if command -v adb &> /dev/null; then
    DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
    if [ "$DEVICES" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Found $DEVICES connected device(s)/emulator(s)"
        adb devices | grep "device$"
    else
        echo -e "${YELLOW}⚠${NC} No devices or emulators connected"
        echo -e "  ${BLUE}Tip:${NC} Connect a device or start an emulator to test your app"
    fi
fi

# Check if we're in a Cordova project
echo
echo -e "${BLUE}Checking current directory...${NC}"
if [ -f "config.xml" ]; then
    echo -e "${GREEN}✓${NC} Cordova project detected (config.xml found)"

    # Check if Android platform is added
    if [ -d "platforms/android" ]; then
        echo -e "${GREEN}✓${NC} Android platform added"
    else
        echo -e "${YELLOW}⚠${NC} Android platform not added"
        echo -e "  ${BLUE}Run:${NC} cordova platform add android"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Not in a Cordova project directory"
    echo -e "  ${BLUE}Tip:${NC} Navigate to your Cordova project root"
fi

# Summary
echo
echo -e "${GREEN}=== Summary ===${NC}"
if [ $ISSUES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! You're ready to build Android apps.${NC}"
elif [ $ISSUES -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found, but you can still build.${NC}"
else
    echo -e "${RED}✗ $ISSUES critical issue(s) found. Please fix them before building.${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS additional warning(s) found.${NC}"
    fi
fi

exit $ISSUES
