#!/bin/bash

# 设置 Cordova 开发环境变量
# 将此脚本添加到 ~/.bashrc 或在每次构建前运行

# Java 环境（使用 Java 17）
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Android SDK
export ANDROID_HOME=/home/codespace/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Node/Cordova
export PATH=$HOME/nvm/current/bin:$PATH

echo "环境变量已设置："
echo "  JAVA_HOME=$JAVA_HOME"
echo "  ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "验证："
java -version 2>&1 | head -1
echo "Cordova: $(cordova -v 2>/dev/null || echo '未找到')"
echo ""
