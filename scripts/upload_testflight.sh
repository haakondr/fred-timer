#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Fred Timer - TestFlight Upload Script${NC}\n"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Must run from project root directory${NC}"
    exit 1
fi

# Build the IPA
echo -e "${YELLOW}📦 Building iOS release IPA...${NC}"
flutter build ipa --release

# Check if build succeeded
IPA_PATH="build/ios/ipa/quiet_timer.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}Error: IPA file not found at $IPA_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ IPA built successfully${NC}\n"

# Upload to App Store Connect
echo -e "${YELLOW}📤 Uploading to App Store Connect...${NC}"
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

# Upload using xcrun altool (deprecated but still works) or newer notarytool
# For App Store Connect uploads, altool is still used
xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --username "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Upload successful!${NC}"
    echo -e "${GREEN}Your build will appear in App Store Connect TestFlight after processing (5-15 minutes)${NC}"
    echo -e "${GREEN}Check status at: https://appstoreconnect.apple.com${NC}"
else
    echo -e "\n${RED}✗ Upload failed${NC}"
    exit 1
fi
