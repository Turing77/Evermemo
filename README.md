# 常记 Evermemo

> 把今日一念，留给来日回望。

一款极简风格的个人随想记录 App，支持深色/浅色主题切换，支持 iOS、Android、Web 多平台，云端同步。

---

## 技术栈

| 类别 | 技术 | 说明 |
|------|------|------|
| 框架 | Flutter 3.x | 跨平台 UI 框架 |
| 语言 | Dart 3.x | |
| 状态管理 | Riverpod 2.6 | 响应式状态管理 |
| 本地数据库 | sqflite | SQLite 本地存储 |
| 云端后端 | Supabase | PostgreSQL + Auth |
| 持久化 | shared_preferences | 轻量键值存储 |
| 图片选择 | image_picker | 相册/拍照 |
| 录音 | record | 语音录制 |
| 分享导出 | share_plus | 系统分享 |
| 通知 | flutter_local_notifications | 本地提醒 |
| UUID | uuid | 唯一 ID 生成 |
| 图标生成 | flutter_launcher_icons | 自定义 App 图标 |

## 项目结构

```
mind_vault/
├── 图标.png                       # App 图标源文件（用于 flutter_launcher_icons）
├── pubspec.yaml                   # 项目配置 & 依赖
├── lib/
│   ├── main.dart                    # 入口，Supabase 初始化
│   ├── app.dart                     # MaterialApp 配置（支持主题切换）
│   ├── models/
│   │   └── thought.dart             # Thought 数据模型
│   ├── database/
│   │   ├── thought_db.dart          # 数据库抽象接口
│   │   ├── thought_db_sqlite.dart   # SQLite 实现（iOS/Android）
│   │   └── thought_db_memory.dart   # 内存实现（Web）
│   ├── providers/
│   │   ├── thought_provider.dart    # Riverpod 状态管理
│   │   └── settings_provider.dart   # 设置项 Provider（主题/字号/提醒）
│   ├── services/
│   │   ├── supabase_service.dart    # Supabase 客户端封装
│   │   └── sync_service.dart        # 双向同步服务
│   ├── screens/
│   │   ├── welcome_screen.dart      # 启动页
│   │   ├── login_screen.dart        # 登录/注册页
│   │   ├── main_tab_screen.dart     # 底部 Tab 容器
│   │   ├── today_screen.dart        # 今日页（首页）
│   │   ├── add_thought_screen.dart  # 写下想法页
│   │   ├── library_screen.dart      # 库页（搜索+列表）
│   │   ├── thought_detail_screen.dart # 想法详情页
│   │   ├── timeline_screen.dart     # 时间线（日历）
│   │   ├── profile_screen.dart      # 我的页面
│   │   ├── favorites_screen.dart    # 收藏列表
│   │   ├── tag_manage_screen.dart   # 标签管理
│   │   ├── settings_screen.dart     # 设置页（主题/字号/提醒配置）
│   │   └── about_screen.dart        # 关于页
│   ├── widgets/
│   │   ├── thought_card.dart        # 想法卡片组件
│   │   └── empty_state.dart         # 空状态占位组件
│   └── utils/
│       ├── theme.dart               # 颜色/主题定义（深色/浅色双主题 + 字号系统）
│       └── animations.dart          # 页面过渡动画
```

## 运行方式

### 环境要求

- Flutter SDK >= 3.0
- Dart >= 3.0
- Android Studio / Xcode（按目标平台）

### 安装依赖

```bash
cd mind_vault
flutter pub get
```

### 运行

```bash
# Android 手机调试
flutter run

# iOS 模拟器
flutter run -d ios

# Web
flutter run -d chrome

# Release 构建
flutter build apk --release
```

### Android 注意事项

- 需要 USB 调试或无线调试连接真机
- Gradle 首次构建较慢，已配置国内镜像加速
- 网络权限已在 AndroidManifest.xml 中声明

### 自定义 App 图标

项目根目录下的 `图标.png` 是 App 图标源文件。如需更换图标：

1. 替换根目录下的 `图标.png`（建议 1024×1024 以上）
2. 运行以下命令自动生成各尺寸图标：

```bash
dart run flutter_launcher_icons
```

图标会自动更新到 Android（mipmap）和 iOS（AppIcon.appiconset）中。

## Supabase 配置

### 1. 创建 Supabase 项目

前往 [supabase.com](https://supabase.com) 注册并创建项目。

### 2. 建表

在 Supabase 后台 -> SQL Editor 中执行：

```sql
create table thoughts (
  id uuid primary key,
  user_id uuid references auth.users not null,
  content text not null,
  tag text,
  is_favorite boolean default false,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

alter table thoughts enable row level security;

create policy "Users can CRUD own thoughts" on thoughts
  for all using (auth.uid() = user_id);
```

### 3. 关闭邮箱验证（开发阶段）

Authentication -> Providers -> Email -> 关闭 Confirm email

### 4. 填写配置

编辑 `lib/services/supabase_service.dart`，替换第 15-16 行：

```dart
const url = 'https://你的项目ID.supabase.co';
const anonKey = '你的 publishable key';
```

- **Project URL**: Project Settings -> Data API -> Project URL
- **Publishable Key**: Project Settings -> API -> publishable key

## 数据同步机制

```
本地 SQLite <-> SyncService <-> Supabase PostgreSQL
```

- **登录后**：全量拉取云端数据，合并到本地
- **增删改后**：自动推送变更到云端
- **冲突策略**：以 updated_at 最新的为准（云端覆盖）
- **图片/语音**：仅存本地，不同步到云端
- **未登录**：纯本地使用，数据不丢失

## 设计风格

- 极简 iOS 风格，支持**深色/浅色主题**切换
- 深色主题：背景色 #0B0F10，强调色 #8DDDBF
- 浅色主题：背景色 #F7F9F8，强调色 #2E9E7A
- 支持**字体大小**调节（小/标准/大）
- 圆角卡片 + 无衬线字体
- 淡入淡出页面过渡动画

## 功能清单

- [x] 写下想法（500 字限制）
- [x] 自定义标签
- [x] 图片附件（最多 3 张）
- [x] 语音备忘
- [x] 收藏功能
- [x] 搜索和标签筛选
- [x] 日历时间线
- [x] 连续记录天数统计
- [x] 数据导出（JSON / 文本）
- [x] 每日提醒（设置页可配置）
- [x] 邮箱注册登录
- [x] Supabase 云端同步
- [x] 多平台支持（iOS / Android / Web）
- [x] 深色/浅色主题切换
- [x] 字体大小调节（小/标准/大）
- [x] 自定义 App 图标
