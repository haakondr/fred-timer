# Deployment Scripts

## TestFlight Upload

Upload a new build to TestFlight via command line.

### Prerequisites

1. **App-specific password**: Generate one at https://appleid.apple.com/account/manage
   - Sign in with your Apple ID
   - Go to "Security" → "App-Specific Passwords"
   - Click "Generate password..."
   - Name it "TestFlight Upload" or similar
   - Copy the password (you'll need it for uploads)

2. **Xcode Command Line Tools**: Already installed if Xcode is installed

### Usage

From the project root:

```bash
./scripts/upload_testflight.sh
```

The script will:
1. Build the release IPA using Flutter
2. Prompt for your Apple ID (if not set in environment)
3. Prompt for your app-specific password (if not set in environment)
4. Upload to App Store Connect
5. Report success/failure

### Environment Variables (Optional)

To avoid being prompted each time, set these environment variables:

```bash
export APPLE_ID="your.email@example.com"
export APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

Add these to your `~/.zshrc` or `~/.bashrc` to make them permanent.

### After Upload

1. Go to https://appstoreconnect.apple.com
2. Navigate to **Apps** → **Fred** → **TestFlight**
3. Wait 5-15 minutes for processing
4. Add internal testers
5. Submit for external testing (requires App Review)

### Troubleshooting

**"altool has been deprecated"**: This is a warning but still works. Apple recommends using the App Store Connect API for automation, but altool is simpler for manual uploads.

**"Invalid credentials"**: Make sure you're using an app-specific password, not your regular Apple ID password.

**"Bundle ID doesn't match"**: Ensure `app.fred.timer` is registered in your Apple Developer account.
