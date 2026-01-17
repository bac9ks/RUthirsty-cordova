---
name: cordova-apk-builder
description: Build Android APK packages from Cordova applications. Use when the user requests to build, package, or compile a Cordova app into an Android APK file, debug APK, or when setting up Android build configuration and signing. Handles environment checks, platform setup, build execution, and signing configuration for Cordova Android projects.
---

# Cordova APK Builder

Build Android APK packages from Cordova applications with automated environment checks, signing setup, and troubleshooting support.

## Quick Start

### For first-time setup or environment issues:
```bash
bash scripts/check_environment.sh
```

This checks for all required tools: Node.js, Cordova, Java JDK, Android SDK, and connected devices.

### To build a debug APK:
```bash
bash scripts/build_cordova_apk.sh
```

This builds a debug APK ready for testing. The script will:
- Verify you're in a Cordova project
- Add Android platform if not present
- Clean and build the APK
- Display APK location and size

### To set up signing configuration:
```bash
bash scripts/setup_android_signing.sh
```

This creates a keystore and build.json for signing APKs. Required for release builds.

## Workflow

### 1. Initial Environment Setup

Before building, verify the environment has all required tools:

```bash
bash scripts/check_environment.sh
```

**What it checks:**
- Node.js and npm installation
- Cordova CLI
- Java JDK (not just JRE)
- Android SDK and ANDROID_HOME environment variable
- Platform tools and build tools
- Connected Android devices/emulators
- Current directory is a Cordova project

**If issues are found:** The script provides specific installation instructions. Most common issues:
- Missing ANDROID_HOME: Set to your Android SDK path
- JRE instead of JDK: Install full Java Development Kit
- Missing platforms: Install with Android Studio SDK Manager

### 2. Building Debug APK

For development and testing, build a debug APK:

```bash
bash scripts/build_cordova_apk.sh
```

**The script handles:**
1. Validates current directory is a Cordova project (checks for config.xml)
2. Adds Android platform if not present
3. Cleans previous builds
4. Builds debug APK
5. Shows APK location and suggests installation command if device is connected

**APK location:** `platforms/android/app/build/outputs/apk/debug/app-debug.apk`

**To install on connected device:**
```bash
adb install -r "path/to/app-debug.apk"
```

### 3. Setting Up Signing (For Release Builds)

To distribute your app or upload to Play Store, you need a signed release build.

**First time setup:**
```bash
bash scripts/setup_android_signing.sh
```

**The script will:**
1. Create a new keystore file (or use existing)
2. Prompt for keystore details:
   - Key alias name
   - Keystore password
   - Key password
   - Certificate information (name, organization, etc.)
3. Generate `build.json` with signing configuration
4. Add signing files to `.gitignore` for security

**Important:**
- **Keep your keystore file safe** - you cannot recover it if lost
- **Never commit** `build.json` or `*.keystore` to version control
- Same keystore must be used for all future updates of your app

**After setup, build signed release APK:**
```bash
cordova build android --release
```

Release APK location: `platforms/android/app/build/outputs/apk/release/app-release.apk`

## Common Scenarios

### Scenario: "Build me an APK"

```bash
# Check environment first
bash scripts/check_environment.sh

# Build debug APK
bash scripts/build_cordova_apk.sh
```

### Scenario: "I need to publish to Play Store"

```bash
# Set up signing (first time only)
bash scripts/setup_android_signing.sh

# Build signed release APK
cordova build android --release

# APK will be at: platforms/android/app/build/outputs/apk/release/app-release.apk
```

### Scenario: "Build is failing"

```bash
# Check environment for issues
bash scripts/check_environment.sh

# If environment looks good, consult troubleshooting guide
# See references/troubleshooting.md for common build errors
```

Read `references/troubleshooting.md` when encountering specific error messages.

### Scenario: "I need to build for different architectures"

By default, Cordova builds a universal APK. To build split APKs per architecture:

1. Edit `platforms/android/app/build.gradle`
2. Add splits configuration:
```gradle
android {
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
            universalApk true
        }
    }
}
```
3. Build normally with `bash scripts/build_cordova_apk.sh`

## Build Configuration

### Customizing Android version targets

Edit `config.xml` to set minimum and target SDK versions:

```xml
<platform name="android">
    <preference name="android-minSdkVersion" value="24" />
    <preference name="android-targetSdkVersion" value="33" />
</platform>
```

### Enabling ProGuard (code minification)

For release builds, enable code shrinking:

```xml
<platform name="android">
    <preference name="android-minifyEnabled" value="true" />
</platform>
```

### Memory configuration

If build fails with OutOfMemoryError, create/edit `gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
org.gradle.daemon=true
org.gradle.parallel=true
```

## Troubleshooting

When builds fail or encounter errors, consult the troubleshooting reference:

**Read `references/troubleshooting.md` for:**
- Environment issues (ANDROID_HOME, Java version, Gradle)
- Build errors (licenses, SDK platforms, build tools)
- Platform and plugin issues
- Signing problems
- Runtime crashes and performance tips

**Quick diagnostic commands:**

```bash
# Check Cordova requirements
cordova requirements

# Verbose build output
cordova build android --verbose

# View device logs
adb logcat | grep -i "error\|exception"
```

## Script Reference

### check_environment.sh
Validates development environment and lists all issues preventing builds.

**Usage:** `bash scripts/check_environment.sh`

**Returns:** Exit code 0 if ready to build, non-zero if critical issues found.

### build_cordova_apk.sh
Builds debug APK with environment validation and helpful output.

**Usage:** `bash scripts/build_cordova_apk.sh`

**Output:** APK path and size, installation command if device connected.

### setup_android_signing.sh
Interactive setup for keystore and build.json configuration.

**Usage:** `bash scripts/setup_android_signing.sh`

**Creates:**
- `my-release-key.keystore` - Keystore file
- `build.json` - Build configuration with signing credentials

## Additional Resources

- **Cordova Android Platform Guide:** https://cordova.apache.org/docs/en/latest/guide/platforms/android/
- **Android Platform Releases:** https://github.com/apache/cordova-android/releases
- **Plugin Search:** https://cordova.apache.org/plugins/

## Notes

- Debug APKs work on any device but cannot be uploaded to Play Store
- Release APKs must be signed and should be optimized (ProGuard enabled)
- Keep your keystore and passwords in a secure location (not in version control)
- Use same keystore for all future updates - losing it means you cannot update your app
