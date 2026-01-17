# Cordova APK 构建 - 故障排除指南

## 当前环境状态

### 已安装的组件
- ✅ Cordova CLI (13.0.0)
- ✅ Node.js (v24.11.1)
- ✅ npm (11.6.2)
- ✅ Java JDK 17 (/usr/lib/jvm/java-17-openjdk-amd64)
- ✅ Android SDK (/home/codespace/Android/Sdk)
  - Platform Tools (36.0.2)
  - Build Tools (34.0.0, 35.0.0)
  - Platform SDK 33, 34, 35

### 已创建的文件
- `build-apk.sh` - 构建脚本
- `config.xml` - Cordova 配置文件（已更新为使用 SDK 34）
- `gradle.properties` - Gradle 配置

## 常见问题和解决方案

### 问题 1: 资源编译错误（appcompat values.xml）

**错误信息:**
```
Invalid <color> for given resource value.
Resource compilation failed
```

**原因:** Gradle 版本与 AndroidX 库版本不兼容

**解决方案:**
1. 使用 Cordova Android 13.0.0（更稳定）
2. 确保使用 Java 17（不是 Java 25）
3. 在 gradle.properties 中增加内存: `org.gradle.jvmargs=-Xmx4096m`

### 问题 2: Gradle XmlParser 错误

**错误信息:**
```
unable to resolve class XmlParser
```

**原因:** Gradle 9.x 与旧版 Cordova 不兼容

**解决方案:**
1. 使用 Cordova Android 13+ (自带 Gradle 8.7)
2. 移除全局 Gradle，让 Cordova 使用自己的 wrapper

### 问题 3: ANDROID_HOME 未设置

**解决方案:**
```bash
export ANDROID_HOME=/home/codespace/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

将这些添加到 `~/.bashrc` 以永久生效：
```bash
echo 'export ANDROID_HOME=/home/codespace/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

## 手动构建步骤

### 方法 1: 使用构建脚本（推荐）

```bash
chmod +x build-apk.sh
./build-apk.sh
```

### 方法 2: 手动逐步构建

```bash
# 1. 设置环境变量
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$HOME/nvm/current/bin:$PATH
export ANDROID_HOME=/home/codespace/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# 2. 验证环境
java -version  # 应该显示 17
cordova -v     # 应该显示 13.0.0
echo $ANDROID_HOME  # 应该显示 SDK 路径

# 3. 清理并重新添加平台（如果需要）
cordova platform remove android
cordova platform add android@13.0.0

# 4. 构建
cordova build android --debug

# 5. 找到 APK
ls -lh platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

### 方法 3: 使用 Android Studio

1. 在 Android Studio 中打开项目的 `platforms/android` 目录
2. 等待 Gradle 同步完成
3. 选择 Build > Build Bundle(s) / APK(s) > Build APK(s)

## 验证构建环境

运行以下命令检查环境是否正确设置：

```bash
# 检查所有要求
cordova requirements

# 检查 Java 版本（应该是 17）
java -version

# 检查 Android SDK
ls $ANDROID_HOME/platforms
ls $ANDROID_HOME/build-tools

# 检查 Cordova 平台
cordova platform ls
```

## 清理构建缓存

如果遇到持续的构建问题，尝试清理缓存：

```bash
# 清理 Cordova 缓存
cordova clean android

# 清理 Gradle 缓存
rm -rf ~/.gradle/caches

# 清理 npm 缓存
npm cache clean --force

# 完全重新开始
cordova platform remove android
rm -rf platforms
rm -rf plugins
cordova platform add android@13.0.0
```

## 替代构建方案

### 使用 GitHub Actions

创建 `.github/workflows/build-apk.yml`：

```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      - name: Setup Android SDK
        uses: android-actions/setup-android@v2
      - name: Build APK
        run: |
          npm install -g cordova
          cordova platform add android@13.0.0
          cordova build android --debug
      - uses: actions/upload-artifact@v3
        with:
          name: app-debug
          path: platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

### 使用 Docker

```bash
# 使用官方 Android 镜像
docker run --rm -v $(pwd):/project -w /project \
  beevelop/cordova:latest \
  bash -c "cordova platform add android@13.0.0 && cordova build android --debug"
```

## 联系支持

如果问题持续存在，请提供以下信息：

1. 完整的错误日志
2. `cordova requirements` 的输出
3. `java -version` 的输出
4. `cordova platform ls` 的输出
5. `config.xml` 的内容
