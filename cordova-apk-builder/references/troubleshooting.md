# Cordova Android Build Troubleshooting

This document covers common issues when building Cordova apps for Android and their solutions.

## Environment Issues

### ANDROID_HOME not set

**Error:**
```
Error: Failed to find 'ANDROID_HOME' environment variable
```

**Solution:**
1. Locate your Android SDK installation (common locations):
   - macOS: `~/Library/Android/sdk`
   - Linux: `~/Android/Sdk`
   - Windows: `C:\Users\<username>\AppData\Local\Android\Sdk`

2. Set ANDROID_HOME environment variable:
   ```bash
   # macOS/Linux (add to ~/.bashrc or ~/.zshrc)
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

   # Windows (PowerShell)
   [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\<username>\AppData\Local\Android\Sdk", "User")
   ```

3. Restart terminal and verify: `echo $ANDROID_HOME`

### Java version issues

**Error:**
```
Unsupported Java version
Could not determine java version from 'X.X.X'
```

**Solution:**
Cordova Android requires Java JDK 11 or later (but not too new - JDK 17 is recommended).

```bash
# Check Java version
java -version

# Install Java 17 (recommended)
# Ubuntu/Debian
sudo apt install openjdk-17-jdk

# macOS (using Homebrew)
brew install openjdk@17

# Set JAVA_HOME
export JAVA_HOME=/path/to/jdk-17
```

### Gradle issues

**Error:**
```
Could not find gradle wrapper within Android SDK
```

**Solution:**
```bash
# Option 1: Let Cordova install Gradle automatically
cordova build android

# Option 2: Install Gradle manually
# Download from https://gradle.org/releases/
# Extract and add to PATH
export PATH=$PATH:/path/to/gradle/bin
```

## Build Errors

### License not accepted

**Error:**
```
Failed to install the following Android SDK packages as some licenses have not been accepted
```

**Solution:**
```bash
# Accept all SDK licenses
cd $ANDROID_HOME
./tools/bin/sdkmanager --licenses

# Or use cmdline-tools
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

### SDK platform not found

**Error:**
```
Failed to find target with hash string 'android-33' in: /path/to/Android/Sdk
```

**Solution:**
```bash
# Install required SDK platform
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-33"

# Or use Android Studio SDK Manager
# Tools → SDK Manager → SDK Platforms → Check Android 13.0 (API 33)
```

### Build tools version conflict

**Error:**
```
Failed to find Build Tools revision XX.X.X
```

**Solution:**
```bash
# Install specific build tools version
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;33.0.0"

# Or update to latest
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --update
```

### Memory issues

**Error:**
```
Expiring Daemon because JVM heap space is exhausted
OutOfMemoryError: Java heap space
```

**Solution:**
Create/edit `gradle.properties` in your project root:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.daemon=true
org.gradle.parallel=true
```

## Platform Issues

### Cannot find module 'cordova-android'

**Error:**
```
Cannot find module 'cordova-android'
```

**Solution:**
```bash
# Remove and re-add Android platform
cordova platform remove android
cordova platform add android@latest

# Or specify version
cordova platform add android@12.0.0
```

### Platform version incompatibility

**Error:**
```
The current project's Cordova Android version does not support...
```

**Solution:**
```bash
# Check current platform version
cordova platform ls

# Update to latest compatible version
cordova platform update android@latest

# Or specify exact version
cordova platform update android@12.0.0
```

## Plugin Issues

### Plugin installation failures

**Error:**
```
Failed to install plugin: PLUGIN_NAME
```

**Solution:**
```bash
# Remove problematic plugin
cordova plugin remove PLUGIN_NAME

# Clear cache and reinstall
rm -rf node_modules plugins platforms/android
npm install
cordova platform add android
cordova plugin add PLUGIN_NAME
```

### AndroidX migration issues

**Error:**
```
Cannot resolve dependency conflicts with AndroidX
```

**Solution:**
Install jetifier plugin to automatically convert old support libraries:
```bash
cordova plugin add cordova-plugin-androidx-adapter
```

## Signing Issues

### Keystore errors

**Error:**
```
Keystore file does not exist
```

**Solution:**
Verify build.json paths are correct:
```json
{
    "android": {
        "release": {
            "keystore": "/absolute/path/to/keystore.keystore",
            "storePassword": "your-password",
            "alias": "your-alias",
            "password": "your-key-password"
        }
    }
}
```

### Wrong keystore password

**Error:**
```
Keystore was tampered with, or password was incorrect
```

**Solution:**
- Verify password in build.json is correct
- If you forgot password, you'll need to create a new keystore (cannot recover)
- For debug builds, keystore is optional

## Runtime Errors

### App crashes on launch

**Possible causes and solutions:**

1. **Missing plugins:**
   ```bash
   # Rebuild with plugins
   cordova platform remove android
   cordova platform add android
   cordova build android
   ```

2. **Min SDK version too low:**
   Edit `config.xml`:
   ```xml
   <preference name="android-minSdkVersion" value="24" />
   ```

3. **Check logcat for details:**
   ```bash
   adb logcat | grep -i "error\|exception"
   ```

### White screen on launch

**Solutions:**
1. Check `www/` folder has all necessary files
2. Verify index.html path in config.xml
3. Clear app data and reinstall
4. Check for JavaScript errors in logcat

## Performance Tips

### Reduce APK size

1. Use ProGuard minification:
   ```xml
   <!-- config.xml -->
   <platform name="android">
       <preference name="android-minifyEnabled" value="true" />
   </platform>
   ```

2. Remove unused resources:
   ```bash
   # Enable resource shrinking
   cordova build android --release -- --shrinkResources
   ```

3. Generate split APKs for different architectures:
   ```xml
   <platform name="android">
       <preference name="android-enable-multidex" value="true" />
   </platform>
   ```

### Improve build speed

1. Enable Gradle daemon (already in gradle.properties above)
2. Use offline mode when no updates needed:
   ```bash
   cordova build android -- --offline
   ```
3. Clear build cache if needed:
   ```bash
   cordova clean android
   ```

## Getting More Help

1. **Check Cordova version compatibility:**
   ```bash
   cordova requirements
   ```

2. **Verbose build output:**
   ```bash
   cordova build android --verbose
   ```

3. **Check logcat for runtime errors:**
   ```bash
   adb logcat ActivityManager:I MyApp:D *:S
   ```

4. **Cordova documentation:**
   - https://cordova.apache.org/docs/en/latest/
   - https://github.com/apache/cordova-android
