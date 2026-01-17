# 使用 Android Studio 构建 APK

由于命令行构建环境存在资源编译问题，推荐使用 Android Studio 直接构建 APK。

## 方法 1: 使用 Android Studio（推荐）

1. **打开项目**
   - 启动 Android Studio
   - 选择 "Open an Existing Project"
   - 导航到 `/workspaces/RUthirsty-cordova/platforms/android`
   - 点击 "OK"

2. **等待 Gradle 同步**
   - Android Studio 会自动开始 Gradle 同步
   - 等待同步完成（可能需要几分钟）

3. **构建 APK**
   - 点击菜单：Build > Build Bundle(s) / APK(s) > Build APK(s)
   - 或者使用快捷键：`Ctrl+Shift+F9` (Linux/Windows) 或 `Cmd+Shift+F9` (Mac)

4. **找到 APK**
   - 构建完成后，Android Studio 会显示一个通知
   - 点击 "locate" 查看 APK 位置
   - APK 通常位于：`app/build/outputs/apk/debug/app-debug.apk`

## 方法 2: 使用 GitHub Actions 自动构建

创建 `.github/workflows/build-android.yml`：

```yaml
name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'

    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'temurin'
        java-version: '17'

    - name: Setup Android SDK
      uses: android-actions/setup-android@v2

    - name: Install Cordova
      run: npm install -g cordova

    - name: Install dependencies
      run: npm install

    - name: Add Android platform
      run: cordova platform add android@13.0.0

    - name: Build APK
      run: cordova build android --debug --verbose

    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug
        path: platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

使用方法：
1. 将上述内容保存为 `.github/workflows/build-android.yml`
2. 提交并推送到 GitHub
3. GitHub Actions 会自动构建 APK
4. 在 Actions 页面下载构建好的 APK

## 方法 3: 使用在线构建服务

### PhoneGap Build 替代方案
由于 PhoneGap Build 已停止服务，可以使用以下替代方案：

1. **Ionic Appflow** (https://ionic.io/appflow)
   - 支持 Cordova 项目
   - 提供免费套餐
   - 云端构建，无需本地环境

2. **Monaca** (https://monaca.io/)
   - 支持 Cordova/PhoneGap
   - 提供免费套餐
   - 可在线编辑和构建

3. **Capacitor** (从 Cordova 迁移)
   - 更现代的替代方案
   - 更好的工具链支持
   - 迁移相对简单

## 方法 4: 使用 Docker 容器

创建 `Dockerfile.android`:

```dockerfile
FROM beevelop/cordova:latest

WORKDIR /app
COPY . .

RUN cordova platform add android@13.0.0
RUN cordova build android --debug

CMD ["tail", "-f", "/dev/null"]
```

使用方法：
```bash
# 构建镜像
docker build -f Dockerfile.android -t ruthirsty-android .

# 运行并构建
docker run --rm -v $(pwd):/app -w /app beevelop/cordova:latest \
  bash -c "cordova platform add android@13.0.0 && cordova build android --debug"

# 复制 APK
docker cp ruthirsty-android:/app/platforms/android/app/build/outputs/apk/debug/app-debug.apk ./
```

## 本地机器构建

如果你有本地 Windows/Mac/Linux 机器：

### Windows
1. 安装 Android Studio
2. 安装 Node.js
3. 安装 Cordova: `npm install -g cordova`
4. 在项目目录运行: `cordova build android --debug`

### macOS
```bash
# 安装 Homebrew（如果还没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装依赖
brew install node
npm install -g cordova

# 构建
cd /path/to/RUthirsty-cordova
cordova build android --debug
```

### Linux (Ubuntu/Debian)
```bash
# 安装依赖
sudo apt update
sudo apt install nodejs npm default-jdk android-sdk

# 安装 Cordova
sudo npm install -g cordova

# 设置环境变量
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# 构建
cd /path/to/RUthirsty-cordova
cordova build android --debug
```

## 为什么命令行构建失败？

当前环境中的问题：
1. AAPT2 (Android Asset Packaging Tool 2) 版本与 AndroidX 库不完全兼容
2. Devcontainer 环境的特殊配置导致资源编译失败
3. 这是一个已知的环境相关问题，不是代码问题

## 获取帮助

如果以上方法都无法工作，请提供：
1. 你的操作系统和版本
2. 是否有访问 Android Studio 的权限
3. 是否可以使用云构建服务

我可以提供更具体的指导。
