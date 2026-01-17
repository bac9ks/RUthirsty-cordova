#!/bin/bash

# Cordova Android APK 构建脚本
# 用于解决环境兼容性问题

set -e

echo "=== Cordova Android APK 构建脚本 ==="
echo ""

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 设置 Java 环境（使用 Java 17 以兼容 Gradle）
echo -e "${YELLOW}步骤 1: 设置 Java 环境${NC}"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo "JAVA_HOME=$JAVA_HOME"
java -version
echo ""

# 2. 设置 Android SDK 环境
echo -e "${YELLOW}步骤 2: 设置 Android SDK 环境${NC}"
export ANDROID_HOME=/home/codespace/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
echo "ANDROID_HOME=$ANDROID_HOME"
echo ""

# 3. 设置 Cordova 路径
echo -e "${YELLOW}步骤 3: 设置 Cordova 路径${NC}"
export PATH=$HOME/nvm/current/bin:$PATH
which cordova
cordova -v
echo ""

# 4. 清理之前的构建（可选）
echo -e "${YELLOW}步骤 4: 清理之前的构建${NC}"
if [ -d "platforms/android" ]; then
    cordova clean android || echo "清理失败，继续..."
fi
echo ""

# 5. 尝试构建 APK（使用 Cordova Android 13）
echo -e "${YELLOW}步骤 5: 构建 APK${NC}"
echo "使用 Cordova Android 13.0.0"
echo ""

# 确保使用 Cordova Android 13
if ! cordova platform ls | grep -q "android 13"; then
    echo "正在安装 Cordova Android 13.0.0..."
    cordova platform remove android 2>/dev/null || true
    cordova platform add android@13.0.0
fi

# 构建调试 APK
echo "开始构建..."
cordova build android --debug --verbose

# 检查构建结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== 构建成功！ ===${NC}"
    echo ""

    # 查找生成的 APK
    APK_PATH="platforms/android/app/build/outputs/apk/debug/app-debug.apk"
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
        echo -e "${GREEN}APK 位置:${NC} $APK_PATH"
        echo -e "${GREEN}APK 大小:${NC} $APK_SIZE"
        echo ""

        # 检查是否有连接的设备
        if command -v adb &> /dev/null; then
            DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
            if [ $DEVICES -gt 0 ]; then
                echo -e "${GREEN}检测到连接的设备！${NC}"
                echo "安装到设备的命令:"
                echo "  adb install -r \"$APK_PATH\""
            fi
        fi
    fi
else
    echo ""
    echo -e "${RED}=== 构建失败 ===${NC}"
    echo ""
    echo "可能的解决方案："
    echo "1. 检查上面的错误信息"
    echo "2. 尝试更新 config.xml 中的 SDK 版本"
    echo "3. 清理 Gradle 缓存: rm -rf ~/.gradle/caches"
    echo "4. 尝试使用不同的 Cordova Android 版本"
    echo ""
    exit 1
fi
