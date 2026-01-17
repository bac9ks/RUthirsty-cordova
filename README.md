# 喝水打卡应用

![Build Android APK](https://github.com/YOUR_USERNAME/RUthirsty-cordova/actions/workflows/build-android.yml/badge.svg)

一个基于 Cordova 开发的简单喝水打卡应用，帮助你养成良好的喝水习惯。

> **提示：** 将上方徽章中的 `YOUR_USERNAME` 替换为你的 GitHub 用户名即可显示构建状态。

## 功能特点

- 一键打卡记录喝水时间
- 实时显示今日喝水次数
- 完整的打卡历史记录列表
- 支持删除单条记录和清空所有记录
- 数据本地存储，无需网络连接
- 精美的渐变UI设计
- 支持安卓设备

## 项目结构

```
RUthirsty-cordova/
├── config.xml              # Cordova 配置文件
├── www/                    # 应用源代码
│   ├── index.html         # 主页面
│   ├── css/
│   │   └── index.css      # 样式文件
│   └── js/
│       └── index.js       # 应用逻辑
└── README.md              # 说明文档
```

## 环境要求

- Node.js (建议 14.x 或更高版本)
- Cordova CLI (`npm install -g cordova`)
- Android Studio (用于安卓开发)
- JDK 8 或更高版本
- Android SDK

## 安装步骤

1. 克隆项目

```bash
git clone <repository-url>
cd RUthirsty-cordova
```

2. 安装 Cordova (如果还没安装)

```bash
npm install -g cordova
```

3. 添加安卓平台

```bash
cordova platform add android
```

## 构建和运行

### ⚡ 使用 GitHub Actions 自动构建（推荐）

本项目已配置 GitHub Actions，可以在云端自动构建 APK，无需本地环境配置！

**快速开始：**
1. 将代码推送到 GitHub
2. 访问仓库的 "Actions" 标签
3. 等待构建完成（约 3-5 分钟）
4. 下载构建好的 APK

**详细说明：** 请查看 [GitHub Actions 构建指南](./GITHUB_ACTIONS_GUIDE.md)

**手动触发构建：**
1. 访问 GitHub 仓库的 "Actions" 页面
2. 选择 "Build Android APK"
3. 点击 "Run workflow"

### 在浏览器中测试

```bash
cordova serve
```

然后在浏览器中访问 http://localhost:8000

### 在安卓设备上运行

1. 连接安卓设备并启用USB调试模式

2. 运行应用

```bash
cordova run android
```

### 本地构建 APK

**注意：** 如果本地构建遇到问题，建议使用上面的 GitHub Actions 方式。

```bash
# 构建调试版本
cordova build android

# 构建发布版本
cordova build android --release
```

生成的 APK 文件位于：
`platforms/android/app/build/outputs/apk/`

**本地构建故障排除：** 如遇到问题，请查看 [BUILD_TROUBLESHOOTING.md](./BUILD_TROUBLESHOOTING.md) 或 [ALTERNATIVE_BUILD_METHODS.md](./ALTERNATIVE_BUILD_METHODS.md)

## 使用说明

1. 打开应用后，点击中央的大水滴按钮进行打卡
2. 每次打卡会自动记录当前时间
3. 顶部显示今日已喝水次数
4. 下方列表显示所有打卡记录
5. 可以单独删除某条记录，或点击"清空记录"删除所有记录

## 技术栈

- Apache Cordova
- HTML5
- CSS3
- JavaScript (原生)
- LocalStorage (本地数据存储)

## 开发说明

- 应用使用 LocalStorage 存储数据，数据保存在设备本地
- 支持设备就绪事件 (deviceready) 和 DOM加载事件 (DOMContentLoaded)
- 所有记录按时间倒序显示（最新的在最上面）
- 今日记录会显示"今天"，历史记录显示具体日期

## 许可证

MIT License