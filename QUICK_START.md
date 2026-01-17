# 🚀 快速开始 - GitHub Actions 自动构建

欢迎！这个指南将帮助你在 5 分钟内使用 GitHub Actions 自动构建你的第一个 APK。

## 📋 步骤概览

1. ✅ 准备代码
2. ✅ 推送到 GitHub
3. ⏳ 等待自动构建
4. 📥 下载 APK

---

## 详细步骤

### 步骤 1: 准备代码 ✅

你已经完成了这一步！项目中已包含：
- ✅ GitHub Actions workflow 文件
- ✅ Cordova 配置文件
- ✅ 应用源代码

### 步骤 2: 推送到 GitHub

#### 2.1 初始化 Git 仓库（如果还没有）

```bash
cd /workspaces/RUthirsty-cordova
git init
git add .
git commit -m "Initial commit with GitHub Actions support"
```

#### 2.2 连接到 GitHub

在 GitHub 上创建一个新仓库，然后：

```bash
# 替换为你的仓库 URL
git remote add origin https://github.com/YOUR_USERNAME/RUthirsty-cordova.git
git branch -M main
git push -u origin main
```

**或者使用 GitHub CLI：**

```bash
# 如果已安装 gh CLI
gh repo create RUthirsty-cordova --public --source=. --remote=origin
git push -u origin main
```

### 步骤 3: 查看自动构建 ⏳

1. **访问 GitHub Actions 页面**
   - 打开你的 GitHub 仓库
   - 点击顶部的 "Actions" 标签
   - 你应该看到 "Build Android APK" workflow 正在运行 🔄

2. **查看构建进度**
   - 点击正在运行的 workflow
   - 可以实时查看每个步骤的进度
   - 通常需要 3-5 分钟完成

3. **等待成功标志**
   - 绿色的 ✅ 表示构建成功
   - 红色的 ❌ 表示构建失败（查看日志排查问题）

### 步骤 4: 下载 APK 📥

#### 构建成功后：

1. **找到 Artifacts**
   - 在 workflow 运行页面向下滚动
   - 找到 "Artifacts" 部分
   - 你会看到 `app-debug-apk`

2. **下载 APK**
   - 点击 `app-debug-apk` 下载 ZIP 文件
   - 解压 ZIP 文件
   - 得到 `app-debug.apk`

3. **安装到手机**
   - 将 APK 传输到 Android 手机
   - 在手机上打开文件管理器
   - 点击 APK 文件安装
   - （首次需要允许安装未知来源的应用）

---

## 🎉 成功！

恭喜！你已经成功使用 GitHub Actions 构建了第一个 APK！

### 接下来做什么？

✅ **每次更新代码：**
```bash
git add .
git commit -m "Update features"
git push
```
推送后会自动触发新的构建！

✅ **发布正式版本：**
```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```
这会触发发布版构建并创建 GitHub Release。

✅ **手动触发构建：**
- 访问 Actions 页面
- 选择 workflow
- 点击 "Run workflow" 按钮

---

## 💡 提示

### 查看构建状态徽章

在 README.md 中更新这行：

```markdown
![Build Android APK](https://github.com/YOUR_USERNAME/RUthirsty-cordova/actions/workflows/build-android.yml/badge.svg)
```

将 `YOUR_USERNAME` 替换为你的 GitHub 用户名。

### 首次构建较慢

第一次构建需要下载所有依赖，可能需要 5-8 分钟。
后续构建会使用缓存，通常 3-5 分钟完成。

### 同时进行多个构建

你可以同时触发多个构建（例如不同的分支），GitHub Actions 会排队处理。

---

## 🆘 遇到问题？

### 构建失败

1. 点击失败的 workflow run
2. 查看红色 ❌ 的步骤
3. 展开查看详细错误信息
4. 参考 [故障排除指南](./BUILD_TROUBLESHOOTING.md)

### 常见问题

**Q: 找不到 Artifacts**
A: 检查构建是否成功完成（绿色 ✅）

**Q: 下载的不是 APK**
A: GitHub 会将 artifacts 打包为 ZIP，需要解压

**Q: 手机无法安装 APK**
A: 在手机设置中允许安装未知来源的应用

---

## 📚 更多资源

- 📖 [完整的 GitHub Actions 指南](./GITHUB_ACTIONS_GUIDE.md)
- 🔧 [故障排除指南](./BUILD_TROUBLESHOOTING.md)
- 🛠️ [其他构建方法](./ALTERNATIVE_BUILD_METHODS.md)

---

**准备好了吗？** 现在就推送代码到 GitHub，开始你的第一次自动构建吧！🚀
