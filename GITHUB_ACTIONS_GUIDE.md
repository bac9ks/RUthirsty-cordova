# GitHub Actions 自动构建 APK 指南

本项目已配置 GitHub Actions 来自动构建 Android APK。每次推送代码或手动触发时，GitHub 会在云端自动构建你的应用。

## 📋 目录

- [快速开始](#快速开始)
- [Workflows 说明](#workflows-说明)
- [如何使用](#如何使用)
- [下载构建的 APK](#下载构建的-apk)
- [配置签名密钥（可选）](#配置签名密钥可选)
- [故障排除](#故障排除)

---

## 🚀 快速开始

### 前提条件

1. 项目已推送到 GitHub 仓库
2. GitHub Actions 已启用（默认启用）

### 第一次使用

1. **推送代码到 GitHub**
   ```bash
   git add .
   git commit -m "Setup GitHub Actions for APK build"
   git push origin main
   ```

2. **查看构建状态**
   - 访问你的 GitHub 仓库
   - 点击 "Actions" 标签
   - 你应该看到 "Build Android APK" workflow 正在运行

3. **等待构建完成**（通常需要 3-5 分钟）

4. **下载 APK**
   - 点击完成的 workflow run
   - 在 "Artifacts" 部分找到 `app-debug-apk`
   - 点击下载 ZIP 文件
   - 解压后即可获得 APK 文件

---

## 📦 Workflows 说明

本项目包含两个 GitHub Actions workflows：

### 1. Build Android APK (build-android.yml)

**用途：** 构建调试版本的 APK

**触发条件：**
- 推送到 `main` 分支时自动触发
- 创建 Pull Request 到 `main` 分支时自动触发
- 在 Actions 页面手动触发

**构建产物：**
- `app-debug-apk` - 调试版本的 APK（可直接安装和测试）

**特点：**
- ✅ 无需签名配置
- ✅ 可直接安装到设备
- ✅ 适合开发和测试

### 2. Build Release APK (build-release.yml)

**用途：** 构建发布版本的 APK

**触发条件：**
- 创建以 `v` 开头的 tag 时（例如 `v1.0.0`）
- 在 Actions 页面手动触发

**构建产物：**
- `app-release-unsigned.apk` - 未签名的发布版 APK
- 如果是 tag 触发，还会创建 GitHub Release

**特点：**
- ⚠️  需要签名才能发布到 Google Play
- 📦 自动创建 GitHub Release
- 🎯 适合正式发布

---

## 🎯 如何使用

### 方法 1: 推送代码自动构建（推荐）

每次推送代码到 `main` 分支，都会自动触发构建：

```bash
# 1. 修改代码
# 2. 提交更改
git add .
git commit -m "Update app features"

# 3. 推送到 GitHub（自动触发构建）
git push origin main
```

### 方法 2: 手动触发构建

1. 访问你的 GitHub 仓库
2. 点击 "Actions" 标签
3. 在左侧选择 "Build Android APK"
4. 点击右上角的 "Run workflow" 按钮
5. 选择分支（通常是 `main`）
6. 点击绿色的 "Run workflow" 按钮

### 方法 3: 创建 Tag 构建发布版

创建一个版本标签来触发发布版本构建：

```bash
# 1. 创建 tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# 2. 推送 tag 到 GitHub（自动触发发布版构建）
git push origin v1.0.0
```

这会：
- 构建发布版 APK
- 自动创建 GitHub Release
- 将 APK 附加到 Release 中

---

## 📥 下载构建的 APK

### 从 Artifacts 下载

1. 访问 GitHub 仓库的 "Actions" 页面
2. 点击你想要的 workflow run（绿色的表示成功）
3. 向下滚动到 "Artifacts" 部分
4. 点击 `app-debug-apk` 下载 ZIP 文件
5. 解压 ZIP 文件得到 `app-debug.apk`

### 从 Releases 下载（仅发布版）

如果是通过 tag 触发的构建：

1. 访问仓库的 "Releases" 页面
2. 找到对应的版本
3. 在 "Assets" 部分直接下载 APK

---

## 🔐 配置签名密钥（可选）

如果要构建可发布到 Google Play 的 APK，需要配置签名密钥。

### 步骤 1: 创建签名密钥

在本地机器上运行：

```bash
keytool -genkey -v \
  -keystore ruthirsty-release.keystore \
  -alias ruthirsty \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_KEYSTORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD
```

⚠️  **重要：** 妥善保存这个 keystore 文件和密码！丢失后无法恢复，且无法更新已发布的应用。

### 步骤 2: 将密钥转换为 Base64

```bash
# Linux/macOS
base64 ruthirsty-release.keystore > keystore.base64.txt

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ruthirsty-release.keystore")) > keystore.base64.txt
```

### 步骤 3: 添加到 GitHub Secrets

1. 访问 GitHub 仓库
2. 进入 Settings > Secrets and variables > Actions
3. 点击 "New repository secret"
4. 添加以下 secrets：

   | Name | Value | 说明 |
   |------|-------|------|
   | `ANDROID_KEYSTORE_BASE64` | keystore.base64.txt 的内容 | Base64 编码的 keystore |
   | `KEYSTORE_PASSWORD` | YOUR_KEYSTORE_PASSWORD | Keystore 密码 |
   | `KEY_ALIAS` | ruthirsty | Key 别名 |
   | `KEY_PASSWORD` | YOUR_KEY_PASSWORD | Key 密码 |

### 步骤 4: 更新 Workflow

修改 `.github/workflows/build-release.yml`，在 "Build release APK" 步骤之前添加：

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > ruthirsty-release.keystore

- name: Create build.json
  run: |
    cat > build.json <<EOF
    {
      "android": {
        "release": {
          "keystore": "ruthirsty-release.keystore",
          "storePassword": "${{ secrets.KEYSTORE_PASSWORD }}",
          "alias": "${{ secrets.KEY_ALIAS }}",
          "password": "${{ secrets.KEY_PASSWORD }}"
        }
      }
    }
    EOF
```

---

## 🛠️ 故障排除

### 构建失败

**查看日志：**
1. 点击失败的 workflow run
2. 点击失败的步骤（红色 ❌）
3. 查看详细错误信息

**常见问题：**

#### 问题 1: "No such file or directory: config.xml"
**原因：** config.xml 不在仓库中
**解决：** 确保 `config.xml` 已提交到 Git

```bash
git add config.xml
git commit -m "Add config.xml"
git push
```

#### 问题 2: "Error: Package name not found"
**原因：** config.xml 配置不正确
**解决：** 检查 config.xml 中的 `<widget id="">` 是否正确配置

#### 问题 3: "Build failed with exit code 1"
**原因：** 依赖或代码问题
**解决：**
1. 检查 www 目录中的代码是否有语法错误
2. 检查是否有缺失的 npm 依赖
3. 在本地尝试构建以复现问题

### Artifacts 找不到

**可能原因：**
1. 构建失败（检查 workflow 状态）
2. Artifacts 已过期（默认保留 30 天）
3. 权限问题

**解决：**
- 重新运行 workflow
- 检查仓库权限设置

### 下载的文件不是 APK

**原因：** GitHub 将 artifacts 打包为 ZIP 文件

**解决：** 解压下载的 ZIP 文件，里面包含 APK

---

## 📊 查看构建状态徽章

在 README.md 中添加构建状态徽章：

```markdown
![Build Android APK](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/build-android.yml/badge.svg)
```

将 `YOUR_USERNAME` 和 `YOUR_REPO` 替换为你的 GitHub 用户名和仓库名。

---

## 🔄 更新 Cordova 版本

如果需要更新 Cordova Android 版本，修改 workflow 文件中的版本号：

```yaml
- name: Add Android platform
  run: cordova platform add android@14.0.0  # 修改这里
```

---

## 💡 提示

1. **首次构建较慢：** 首次构建需要下载所有依赖，可能需要 5-10 分钟。后续构建会使用缓存，通常 3-5 分钟完成。

2. **并行构建：** 可以同时触发多个构建，GitHub Actions 会排队处理。

3. **保留时间：** 调试版 APK 保留 30 天，发布版保留 90 天。

4. **私有仓库：** 如果是私有仓库，注意 GitHub Actions 的使用额度。

5. **查看完整日志：** 点击每个步骤可以查看详细的构建日志，方便调试。

---

## 📚 更多资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Cordova Android 平台指南](https://cordova.apache.org/docs/en/latest/guide/platforms/android/)
- [Android 应用签名](https://developer.android.com/studio/publish/app-signing)

---

## 🆘 获取帮助

如果遇到问题：
1. 检查 Actions 页面的构建日志
2. 查看本文档的故障排除部分
3. 在仓库中创建 Issue

---

**祝你构建愉快！** 🎉
