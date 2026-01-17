#!/bin/bash

# Cordova Android APK 构建脚本 v2
# 临时禁用全局 Gradle 以避免兼容性问题

set -e

echo "=== Cordova Android APK 构建脚本 v2 ==="
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

# 4. 临时禁用全局 Gradle
echo -e "${YELLOW}步骤 4: 临时禁用全局 Gradle${NC}"
ORIGINAL_PATH="$PATH"
# 从 PATH 中移除包含 gradle 的路径
export PATH=$(echo $PATH | tr ':' '\n' | grep -v gradle | tr '\n' ':' | sed 's/:$//')
echo "已从 PATH 中移除 Gradle"
echo ""

which cordova
cordova -v
echo ""

# 5. 清理之前的构建
echo -e "${YELLOW}步骤 5: 清理之前的构建${NC}"
if [ -d "platforms/android" ]; then
    # 先重新添加 Gradle 到 PATH 来执行清理
    export PATH="$ORIGINAL_PATH"
    cordova clean android || echo "清理失败，继续..."
    # 再次移除 Gradle
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v gradle | tr '\n' ':' | sed 's/:$//')
fi
echo ""

# 6. 确保使用 Cordova Android 13
echo -e "${YELLOW}步骤 6: 确保使用 Cordova Android 13${NC}"
export PATH="$ORIGINAL_PATH"
if ! cordova platform ls 2>/dev/null | grep -q "android 13"; then
    echo "正在安装 Cordova Android 13.0.0..."
    cordova platform remove android 2>/dev/null || true
    cordova platform add android@13.0.0
fi
# 再次移除 Gradle
export PATH=$(echo $PATH | tr ':' '\n' | grep -v gradle | tr '\n' ':' | sed 's/:$//')
echo ""

# 7. 手动创建 Gradle wrapper（如果不存在）
echo -e "${YELLOW}步骤 7: 准备 Gradle wrapper${NC}"
if [ ! -f "platforms/android/gradlew" ]; then
    echo "Gradle wrapper 不存在，需要创建..."
    # 临时恢复 PATH 来下载 wrapper
    export PATH="$ORIGINAL_PATH"
    cd platforms/android
    # 使用兼容的 Gradle 版本手动创建 wrapper
    gradle wrapper --gradle-version 8.7 || echo "Wrapper 创建可能失败"
    cd ../..
    # 再次移除 Gradle
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v gradle | tr '\n' ':' | sed 's/:$//')
fi
echo ""

# 8. 直接使用 Gradle wrapper 构建
echo -e "${YELLOW}步骤 8: 使用 Gradle wrapper 直接构建${NC}"
if [ -f "platforms/android/gradlew" ]; then
    cd platforms/android

    # 使用项目的 gradlew
    echo "使用 ./gradlew 构建..."
    ./gradlew clean
    ./gradlew assembleDebug

    cd ../..

    # 检查构建结果
    APK_PATH="platforms/android/app/build/outputs/apk/debug/app-debug.apk"
    if [ -f "$APK_PATH" ]; then
        echo ""
        echo -e "${GREEN}=== 构建成功！ ===${NC}"
        echo ""
        APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
        echo -e "${GREEN}APK 位置:${NC} $APK_PATH"
        echo -e "${GREEN}APK 大小:${NC} $APK_SIZE"
        echo ""

        # 检查是否有连接的设备
        export PATH="$ORIGINAL_PATH"
        if command -v adb &> /dev/null; then
            DEVICES=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | wc -l)
            if [ $DEVICES -gt 0 ]; then
                echo -e "${GREEN}检测到连接的设备！${NC}"
                echo "安装到设备的命令:"
                echo "  adb install -r \"$(pwd)/$APK_PATH\""
            fi
        fi
        exit 0
    else
        echo ""
        echo -e "${RED}=== APK 文件未找到 ===${NC}"
        exit 1
    fi
else
    echo -e "${RED}Gradle wrapper 不存在，使用 Cordova 构建${NC}"
    # 恢复完整的 PATH
    export PATH="$ORIGINAL_PATH"
    cordova build android --debug
fi
