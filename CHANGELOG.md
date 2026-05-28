# 更新日志

## [1.0.0+ios] - 2026-05-29

### iOS 配置更新

#### 环境配置
- 安装 Flutter SDK (v3.44.0 stable)
- 配置 Xcode 开发环境
- 安装 CocoaPods (v1.16.2)
- 配置 GitHub CLI 认证

#### 项目修改
- **Bundle Identifier**: `com.example.mindVault` → `com.whatpity.evermemo`
- **代码签名**: 启用自动签名管理，配置开发者团队
- **Swift Package Manager**: 集成 iOS 插件依赖管理
- **Xcode 项目**: 升级项目配置以兼容最新 Xcode 版本

#### 修改文件
- `ios/Runner.xcodeproj/project.pbxproj` - 项目配置更新
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme` - 构建方案更新
- `ios/Runner/Base.lproj/Main.storyboard` - 主界面配置
- `macos/Runner.xcodeproj/project.pbxproj` - macOS 项目配置同步更新
- `macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme` - macOS 构建方案
- `pubspec.lock` - 依赖版本锁定文件更新

#### 依赖更新
- 更新 137 个依赖包到最新兼容版本
- 使用 Swift Package Manager 管理 iOS 原生插件

#### 调试配置
- 支持 iOS 真机调试（免费 Apple ID）
- 配置设备信任和证书验证流程

---

## [1.0.0] - 2026-05-28

### 初始版本
- 项目初始化：常记 Evermemo
- 基础功能实现
