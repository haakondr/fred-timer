#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Fred Timer - TestFlight Upload Script${NC}\n"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Must run from project root directory${NC}"
    exit 1
fi

# Bump build number in pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo -e "${YELLOW}Bumping version: ${CURRENT_VERSION} -> ${NEW_VERSION}${NC}"
sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml

# Commit the version bump
git add pubspec.yaml
git commit -m "Bump build number to ${NEW_BUILD_NUMBER} for TestFlight upload"

echo -e "${GREEN}Version bumped and committed${NC}\n"

# Build the IPA
echo -e "${YELLOW}Building iOS release IPA...${NC}"
flutter build ipa --release

# Check if build succeeded
IPA_PATH="build/ios/ipa/quiet_timer.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}Error: IPA file not found at $IPA_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}IPA built successfully${NC}\n"

# Upload to App Store Connect
echo -e "${YELLOW}Uploading to App Store Connect...${NC}"
echo -e "You'll need your Apple ID and an app-specific password"
echo -e "Generate app-specific password at: https://appleid.apple.com/account/manage\n"

# Prompt for credentials if not set in environment
if [ -z "$APPLE_ID" ]; then
    read -p "Apple ID (email): " APPLE_ID
fi

if [ -z "$APP_SPECIFIC_PASSWORD" ]; then
    echo "App-specific password (will be hidden):"
    read -s APP_SPECIFIC_PASSWORD
    echo ""
fi

xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --username "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD"

UPLOAD_RESULT=$?

if [ $UPLOAD_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}Upload successful! (build ${NEW_BUILD_NUMBER})${NC}"
    echo -e "${GREEN}Your build will appear in App Store Connect TestFlight after processing (5-15 minutes)${NC}"
    echo -e "${GREEN}Check status at: https://appstoreconnect.apple.com${NC}"
else
    echo -e "\n${RED}Upload failed${NC}"
    exit 1
fi
