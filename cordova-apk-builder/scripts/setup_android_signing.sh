#!/bin/bash

# Android Signing Configuration Script
# Helps set up signing configuration for Cordova Android builds

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Android Signing Configuration ===${NC}\n"

# Check if we're in a Cordova project
if [ ! -f "config.xml" ]; then
    echo -e "${RED}Error: config.xml not found. Are you in a Cordova project directory?${NC}"
    exit 1
fi

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}Error: keytool not found. Make sure Java JDK is installed.${NC}"
    exit 1
fi

echo -e "${BLUE}This script will help you set up Android signing configuration.${NC}\n"

# Check if keystore already exists
KEYSTORE_FILE="my-release-key.keystore"
BUILD_JSON="build.json"

if [ -f "$KEYSTORE_FILE" ]; then
    echo -e "${YELLOW}Warning: Keystore file '$KEYSTORE_FILE' already exists.${NC}"
    read -p "Do you want to create a new one? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Skipping keystore creation.${NC}"
    else
        rm "$KEYSTORE_FILE"
    fi
fi

# Create keystore if it doesn't exist
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "\n${YELLOW}Creating new keystore...${NC}"
    echo -e "${BLUE}You will be prompted for the following information:${NC}"
    echo -e "  - Keystore password (remember this!)"
    echo -e "  - Key alias name (e.g., 'my-app-key')"
    echo -e "  - Key password (can be same as keystore password)"
    echo -e "  - Your name, organization, city, state, country\n"

    read -p "Enter key alias name [default: my-app-key]: " KEY_ALIAS
    KEY_ALIAS=${KEY_ALIAS:-my-app-key}

    keytool -genkey -v -keystore "$KEYSTORE_FILE" -alias "$KEY_ALIAS" \
            -keyalg RSA -keysize 2048 -validity 10000

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ Keystore created successfully: $KEYSTORE_FILE${NC}"
    else
        echo -e "${RED}Error creating keystore.${NC}"
        exit 1
    fi
else
    read -p "Enter your key alias name: " KEY_ALIAS
fi

# Get passwords
echo -e "\n${YELLOW}Enter signing credentials (for build.json):${NC}"
read -sp "Keystore password: " KEYSTORE_PASSWORD
echo
read -sp "Key password (press Enter if same as keystore password): " KEY_PASSWORD
echo
KEY_PASSWORD=${KEY_PASSWORD:-$KEYSTORE_PASSWORD}

# Create or update build.json
echo -e "\n${YELLOW}Creating build.json configuration...${NC}"

KEYSTORE_PATH="$(pwd)/$KEYSTORE_FILE"

cat > "$BUILD_JSON" <<EOF
{
    "android": {
        "debug": {
            "keystore": "$KEYSTORE_PATH",
            "storePassword": "$KEYSTORE_PASSWORD",
            "alias": "$KEY_ALIAS",
            "password": "$KEY_PASSWORD",
            "keystoreType": ""
        },
        "release": {
            "keystore": "$KEYSTORE_PATH",
            "storePassword": "$KEYSTORE_PASSWORD",
            "alias": "$KEY_ALIAS",
            "password": "$KEY_PASSWORD",
            "keystoreType": ""
        }
    }
}
EOF

echo -e "${GREEN}✓ build.json created successfully${NC}"

# Create .gitignore entry
if [ -f ".gitignore" ]; then
    if ! grep -q "build.json" .gitignore; then
        echo -e "\n# Android signing files" >> .gitignore
        echo "build.json" >> .gitignore
        echo "*.keystore" >> .gitignore
        echo -e "${GREEN}✓ Added build.json and *.keystore to .gitignore${NC}"
    fi
else
    echo -e "build.json\n*.keystore" > .gitignore
    echo -e "${GREEN}✓ Created .gitignore with signing files${NC}"
fi

echo -e "\n${GREEN}=== Configuration Complete ===${NC}"
echo -e "${YELLOW}Important:${NC}"
echo -e "  1. Keep your keystore file safe - you cannot recover it if lost!"
echo -e "  2. Do not commit build.json or *.keystore to version control"
echo -e "  3. To build signed APK, run: cordova build android --release"
echo -e "\n${BLUE}Files created:${NC}"
echo -e "  - $KEYSTORE_FILE (keystore file)"
echo -e "  - $BUILD_JSON (build configuration)"
