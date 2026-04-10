# Reeder Flutter 复刻版 - 产品需求文档 (PRD)

> **项目名称**：Reeder Flutter  
> **版本**：v1.0  
> **日期**：2026-04-09  
> **目标平台**：iOS / Android（Flutter 跨平台）  
> **参考原型**：Reeder (iOS/macOS) by Silvio Rizzi

---

## 一、产品概述

### 1.1 产品定位

Reeder Flutter 是一款以 **极简美学** 和 **沉浸式阅读体验** 为核心的 RSS 阅读器，复刻 iOS 平台上广受好评的 Reeder 应用。它不仅是传统的 RSS 阅读器，更是一个 **统一内容聚合平台**，将 RSS 订阅、播客、视频、社交媒体等多种内容源整合到一个优雅的时间线中。

### 1.2 核心理念

| 理念 | 说明 |
|------|------|
| **告别未读计数** | 用"滚动位置同步"取代传统的未读数机制，减少信息焦虑 |
| **统一时间线** | RSS、视频、播客、社交媒体帖子无缝整合到一条时间线 |
| **极简设计** | 干净、无干扰的阅读界面，专注于内容本身 |
| **隐私优先** | 不收集任何用户数据，所有同步数据存储在用户自己的云端 |

### 1.3 目标用户

- **信息重度消费者**：每天阅读大量博客、新闻、技术文章的用户
- **RSS 爱好者**：习惯通过 RSS 订阅管理信息源的用户
- **内容创作者**：需要追踪行业动态和灵感来源的创作者
- **极简主义者**：厌倦算法推荐、追求自主信息获取的用户

---

## 二、竞品分析

### 2.1 Reeder 原版核心优势分析

| 维度 | 分析 |
|------|------|
| **设计语言** | 遵循 Apple Human Interface Guidelines，大量留白、精致排版、流畅动画 |
| **交互范式** | 滑动手势操作、滚动位置记忆、状态栏快捷操作 |
| **内容呈现** | 根据内容类型（文章/图片/视频/播客/社交帖子）自动选择最佳查看器 |
| **组织方式** | 标签系统 + 文件夹 + 过滤器，灵活的内容分类 |
| **同步策略** | 仅同步关键数据（订阅源、滚动位置、标签项），轻量高效 |

### 2.2 与其他 RSS 阅读器对比

| 特性 | Reeder | NetNewsWire | Feedly | Inoreader |
|------|--------|-------------|--------|-----------|
| 未读计数 | ❌ 滚动位置 | ✅ | ✅ | ✅ |
| 多媒体整合 | ✅ 视频/播客/社交 | ❌ 纯 RSS | 部分 | 部分 |
| 本地优先 | ✅ | ✅ | ❌ 云端 | ❌ 云端 |
| 设计美感 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| 隐私保护 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

---

## 三、功能需求

### 3.1 功能架构总览

```
Reeder Flutter
├── 📡 订阅管理
│   ├── RSS/Atom/JSON Feed 订阅
│   ├── OPML 导入/导出
│   ├── 订阅源发现与搜索
│   ├── 订阅源分组（自动分类 + 自定义文件夹）
│   └── 订阅源设置（自定义查看器、自动 Reader View 等）
│
├── 📰 内容浏览
│   ├── 统一时间线（Home Timeline）
│   ├── 分类时间线（按内容类型自动分组）
│   ├── 文件夹时间线
│   ├── 单订阅源时间线
│   ├── 滚动位置同步
│   └── 时间线控制（跳转到保存位置/今天/顶部）
│
├── 📖 内容阅读
│   ├── 文章查看器（Article Viewer）
│   ├── Reader View（去杂阅读模式）
│   ├── 应用内浏览器（In-App Browser）
│   ├── 图片查看器（Image Viewer）
│   ├── 视频播放器（Video Player）
│   ├── 播客播放器（Podcast Player）
│   ├── 社交帖子查看器（Thread Viewer）
│   └── Bionic Reading 模式
│
├── 🏷️ 内容组织
│   ├── 内置标签（Later / Bookmarks / Favorites）
│   ├── 自定义标签
│   ├── 过滤器（关键词/媒体类型/订阅源类型）
│   ├── 保存链接（Share Extension）
│   └── 搜索
│
├── 🔄 同步与数据
│   ├── 云端同步（订阅/位置/标签项）
│   ├── 第三方服务集成（Feedbin/Feedly/Inoreader 等）
│   ├── 数据导出（OPML/JSON）
│   └── 共享订阅源（公开 JSON Feed）
│
├── ⚙️ 设置与个性化
│   ├── 主题（亮色/暗色/OLED 黑/Dark Light）
│   ├── 排版设置（字号/行高/内容宽度）
│   ├── 布局设置（列宽/头像显示/图标样式）
│   ├── 默认查看器设置
│   ├── 默认应用设置
│   └── 诊断工具
│
└── 🔌 平台能力
    ├── Widget 小组件
    ├── Share Extension
    ├── URL Scheme（reed://）
    └── 快捷键支持（平板/桌面端）
```

### 3.2 核心功能详细设计

---

#### 3.2.1 订阅管理模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **添加 RSS 订阅** | 通过 URL 搜索并添加 RSS/Atom/JSON Feed | 输入 URL 后自动发现 feed，展示 feed 信息预览，确认后添加 |
| **OPML 导入** | 从文件导入 OPML 格式的订阅列表 | 支持标准 OPML 格式，导入时展示 feed 列表供用户选择 |
| **OPML 导出** | 将当前订阅列表导出为 OPML 文件 | 导出文件符合 OPML 2.0 标准，包含文件夹结构 |
| **订阅源分组** | 按内容类型自动分组（Blogs/Podcasts/Videos 等） | 新添加的 feed 自动归入对应类型分组 |
| **自定义文件夹** | 用户可创建文件夹，将不同类型的 feed 混合组织 | 支持创建/重命名/删除文件夹，拖拽 feed 到文件夹 |
| **取消订阅** | 移除订阅源及其所有内容 | 取消订阅后，相关内容从时间线中移除 |
| **订阅源设置** | 每个 feed 可单独设置查看器、自动 Reader View 等 | 长按 feed 弹出设置菜单 |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **Feed 搜索发现** | 输入网站 URL 时自动搜索可用的 RSS feed |
| **Feed 图标** | 自动获取并展示 feed 的 favicon |
| **Feed 刷新诊断** | 展示每个 feed 的刷新耗时，帮助定位慢速 feed |

---

#### 3.2.2 内容浏览模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **统一时间线** | 所有订阅源的内容按时间倒序排列在一条时间线中 | 最新内容在顶部，支持无限滚动加载 |
| **滚动位置同步** | 记录并同步用户在每个时间线中的阅读位置 | 切换设备后能从上次位置继续阅读 |
| **下拉刷新** | 下拉手势触发所有订阅源刷新 | 刷新完成后才显示新内容，避免位置跳动 |
| **时间线控制** | 列表右上角显示新内容计数，点击可跳转 | 支持三种跳转：保存位置/今天/顶部 |
| **分类浏览** | 按内容类型（文章/音频/视频）分别浏览 | 每个分类独立维护滚动位置 |
| **文件夹浏览** | 按文件夹浏览内容 | 文件夹内容独立维护滚动位置 |
| **单源浏览** | 查看单个订阅源的所有内容 | 单源视图独立维护滚动位置 |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **内容过期隐藏** | 可设置隐藏超过指定天数的旧内容 |
| **列表项预览** | 列表项展示标题、摘要、缩略图、来源图标 |
| **多图标识** | 列表项标识包含多张图片的帖子 |
| **标签状态展示** | 列表项展示 Later/Bookmark/Favorite 状态图标 |

---

#### 3.2.3 内容阅读模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **文章查看器** | 渲染 RSS 内容的富文本查看器 | 支持 HTML 内容渲染，包括图片、链接、代码块、引用等 |
| **Reader View** | 提取网页正文的去杂阅读模式 | 去除广告和导航，只保留正文内容和图片 |
| **应用内浏览器** | 内嵌 WebView 浏览原始网页 | 支持前进/后退/刷新/分享，支持外部浏览器打开 |
| **图片查看器** | 全屏查看图片，支持缩放和滑动切换 | 支持双指缩放、左右滑动切换多图 |
| **左滑导航** | 在详情页左滑加载下一篇（更新的）内容 | 滑动流畅，支持从右边缘触发 |
| **排版设置** | 可调节字号和行高 | 设置实时预览，持久化保存 |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **视频播放器** | 内嵌视频播放，支持 YouTube 等平台 |
| **播客播放器** | 内嵌音频播放，支持进度条、章节标记、迷你播放器 |
| **Bionic Reading** | 加粗单词前几个字母以提高阅读速度和专注度 |
| **自动 Reader View** | 可按 feed 设置自动启用 Reader View |
| **内容宽度调节** | 平板端可调节文章内容的最大宽度 |
| **代码块支持** | 文章查看器中正确渲染代码块 |

---

#### 3.2.4 内容组织模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **Later 标签** | 标记内容为"稍后阅读" | 工具栏快捷按钮，列表滑动操作 |
| **Bookmarks 标签** | 收藏内容到书签 | 工具栏快捷按钮，列表滑动操作 |
| **Favorites 标签** | 收藏内容到最爱 | 工具栏快捷按钮，列表滑动操作 |
| **自定义标签** | 创建自定义标签分类内容 | 支持自定义图标和名称 |
| **列表滑动操作** | 左滑/右滑触发快捷操作（标签/分享等） | 滑动操作可自定义 |
| **搜索** | 全文搜索已加载的内容 | 搜索结果高亮关键词 |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **保存链接** | 通过 Share Extension 从外部应用保存链接到 Reeder |
| **Links 文件夹** | 所有保存的链接集中在 Links 文件夹中 |
| **过滤器** | 基于关键词/媒体类型/feed 类型创建自定义时间线 |
| **标签导出** | 将标签内容导出为 JSON Feed 格式文件 |

---

#### 3.2.5 同步与数据模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **本地存储** | 所有内容本地持久化存储 | 使用 SQLite/Isar 等本地数据库 |
| **本地 RSS 解析** | 直接从源获取和解析 RSS/Atom/JSON Feed | 支持标准 RSS 2.0、Atom 1.0、JSON Feed 1.1 |
| **后台刷新** | 应用在后台时定期刷新订阅源 | 利用平台后台任务 API |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **云端同步** | 通过 Firebase/自建服务同步订阅、位置、标签 |
| **第三方服务** | 集成 Feedbin、Feedly、Inoreader 等第三方 RSS 服务 |
| **共享订阅源** | 将标签转为公开的 JSON Feed |

---

#### 3.2.6 设置与个性化模块

##### P0 - 必须实现

| 功能 | 描述 | 验收标准 |
|------|------|----------|
| **亮色主题** | 白色背景的默认主题 | 干净的白色背景，深色文字 |
| **暗色主题** | 深色背景主题 | 深灰背景，浅色文字 |
| **跟随系统** | 自动跟随系统亮/暗模式切换 | 系统切换时实时响应 |
| **字号设置** | 文章阅读字号可调节 | 提供 5-7 档字号选择 |
| **行高设置** | 文章阅读行高可调节 | 提供 3-5 档行高选择 |

##### P1 - 重要功能

| 功能 | 描述 |
|------|------|
| **OLED 黑色主题** | 纯黑背景，适合 OLED 屏幕 |
| **Dark Light 主题** | 暗色列表 + 亮色内容查看器的混合主题 |
| **自定义应用图标** | 提供多种可选的应用图标 |
| **头像/图标显示** | 可选择是否在列表中显示头像/图标 |
| **头像样式** | 圆形/方形头像样式切换 |

---

## 四、界面设计规范

### 4.1 设计原则

| 原则 | 说明 |
|------|------|
| **内容优先** | 界面元素最小化，让内容成为视觉焦点 |
| **大量留白** | 充足的 padding 和 margin，营造呼吸感 |
| **精致排版** | 精心选择的字体、字号、行高、字间距 |
| **流畅动画** | 所有转场和交互都有自然流畅的动画 |
| **手势驱动** | 以手势操作为主，按钮为辅 |

### 4.2 整体布局

#### 手机端（iPhone 布局）

```
┌─────────────────────────┐
│      Status Bar         │  ← 点击状态栏跳转到保存位置
├─────────────────────────┤
│  ← Back    Title   ⋯   │  ← 导航栏（可隐藏）
├─────────────────────────┤
│                         │
│   ┌───────────────────┐ │
│   │ 🔵 Feed Icon      │ │
│   │ Feed Name · 2h    │ │  ← 列表项：图标 + 来源 + 时间
│   │ Article Title     │ │  ← 标题（粗体）
│   │ Summary text...   │ │  ← 摘要（灰色）
│   │ ┌───────────────┐ │ │
│   │ │  Thumbnail    │ │ │  ← 缩略图（可选）
│   │ └───────────────┘ │ │
│   │ 🏷️ Later ⭐ Fav   │ │  ← 标签状态图标
│   └───────────────────┘ │
│   ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │  ← 分隔线（极细）
│   ┌───────────────────┐ │
│   │ Next Article...   │ │
│   └───────────────────┘ │
│                         │
├─────────────────────────┤
│  🏠  📂  🔍  ⚙️        │  ← 底部标签栏（可选）
└─────────────────────────┘
```

#### 手机端导航流程

```
源列表 (Source List)          文章列表 (Article List)        文章详情 (Detail)
┌──────────────────┐        ┌──────────────────┐         ┌──────────────────┐
│ 🏠 Home          │        │ ← Home    12 ▾   │         │ ← Back     ⋯    │
│   📰 All         │ ──→    │                  │  ──→    │                  │
│   🎵 Audio       │        │ Article 1        │         │  Article Title   │
│   🎬 Video       │        │ Article 2        │         │                  │
│   🔍 Filter 1    │        │ Article 3        │         │  Content body    │
│                  │        │ Article 4        │         │  with rich text  │
│ 📁 Feeds         │        │ ...              │         │  and images...   │
│   📰 Blogs       │        │                  │         │                  │
│   🎙️ Podcasts    │        │                  │         │  ┌────────────┐  │
│   📺 YouTube     │        │                  │         │  │   Image    │  │
│   📁 My Folder   │        │                  │         │  └────────────┘  │
│                  │        │                  │         │                  │
│ 🏷️ Tags          │        │                  │         ├──────────────────┤
│   ⏰ Later       │        │                  │         │ ← 🏷️ ⭐ 📤 🌐 → │
│   🔖 Bookmarks   │        │                  │         │   Action Bar     │
│   ❤️ Favorites   │        │                  │         └──────────────────┘
│                  │        │                  │
│ 🔗 Saved         │        │                  │
│   🔗 Links       │        │                  │
└──────────────────┘        └──────────────────┘
```

#### 平板端（iPad 布局）

```
┌────────────┬──────────────────┬──────────────────────────────┐
│ Source List │  Article List    │      Article Detail          │
│            │                  │                              │
│ 🏠 Home    │ Article 1       │  Article Title               │
│   📰 All   │ ─────────────── │                              │
│   🎵 Audio │ Article 2       │  Author · Date               │
│   🎬 Video │ ─────────────── │                              │
│            │ Article 3  ←    │  Content body with rich      │
│ 📁 Feeds   │ ─────────────── │  text formatting, images,    │
│   📰 Blogs │ Article 4       │  and embedded media...       │
│   🎙️ Pod.. │ ─────────────── │                              │
│            │ Article 5       │  ┌────────────────────────┐  │
│ 🏷️ Tags    │                  │  │                        │  │
│   ⏰ Later │                  │  │      Full Image        │  │
│   🔖 Book..│                  │  │                        │  │
│   ❤️ Fav.. │                  │  └────────────────────────┘  │
│            │                  │                              │
│ 🔗 Saved   │                  │  More content continues...   │
│   🔗 Links │                  │                              │
├────────────┤                  ├──────────────────────────────┤
│  + Filter  │                  │  ← 🏷️ ⭐ 📤 🌐 →            │
└────────────┴──────────────────┴──────────────────────────────┘
     240pt        320pt              Flexible Width
```

### 4.3 核心页面设计

---

#### 4.3.1 源列表页 (Source List)

**功能说明**：应用的主导航页面，展示所有内容源的层级结构。

**布局结构**：
```
┌─────────────────────────┐
│  Reeder          + ⚙️   │  ← 顶部：应用名 + 添加/设置按钮
├─────────────────────────┤
│                         │
│  HOME                   │  ← Section Header（大写灰色小字）
│  ┌─────────────────────┐│
│  │ 📰  All             ││  ← 所有内容的统一时间线
│  │ 🎵  Audio           ││  ← 音频过滤器（内置）
│  │ 🎬  Video           ││  ← 视频过滤器（内置）
│  │ 🔍  My Filter       ││  ← 用户自定义过滤器
│  └─────────────────────┘│
│                         │
│  FEEDS                  │  ← Section Header
│  ┌─────────────────────┐│
│  │ 📰  Blogs        12 ││  ← 自动分组 + 可选计数
│  │ 🎙️  Podcasts      3 ││
│  │ 📺  YouTube       8 ││
│  │ 📁  Tech News       ││  ← 用户自定义文件夹
│  │ 📁  Design          ││
│  └─────────────────────┘│
│                         │
│  TAGS                   │  ← Section Header
│  ┌─────────────────────┐│
│  │ ⏰  Later         5 ││  ← 内置标签（可自定义图标/名称）
│  │ 🔖  Bookmarks     2 ││
│  │ ❤️  Favorites    10 ││
│  │ 🏷️  Research        ││  ← 自定义标签
│  └─────────────────────┘│
│                         │
│  SAVED                  │  ← Section Header
│  ┌─────────────────────┐│
│  │ 🔗  Links         3 ││  ← 保存的链接
│  └─────────────────────┘│
│                         │
└─────────────────────────┘
```

**交互说明**：
- **点击**：进入对应的文章列表
- **长按/右键**：弹出上下文菜单（设置/重命名/删除/添加到文件夹等）
- **点击 "+"**：弹出添加菜单（添加订阅/创建文件夹/创建过滤器）
- **计数显示**：可在设置中开启/关闭标签计数

---

#### 4.3.2 文章列表页 (Article List)

**功能说明**：展示某个时间线/文件夹/标签下的所有内容项。

**列表项设计**：
```
┌─────────────────────────────────────┐
│                                     │
│  🔵 The Verge · 2h ago             │  ← 来源图标 + 名称 + 相对时间
│                                     │
│  Apple Announces New MacBook Pro    │  ← 标题（SF Pro Display, 17pt, Semibold）
│  with M5 Chip                      │
│                                     │
│  Apple today unveiled the next      │  ← 摘要（SF Pro Text, 14pt, Regular, 灰色）
│  generation MacBook Pro featuring   │     最多显示 2-3 行
│  the all-new M5 chip...            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │  ← 缩略图（圆角矩形，16:9 比例）
│  │        Thumbnail            │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ⏰ 🔖                              │  ← 标签状态图标（如果有）
│                                     │
└─────────────────────────────────────┘
```

**紧凑列表项（无图模式）**：
```
┌─────────────────────────────────────┐
│  🔵 Daring Fireball · 5h ago       │
│  The iPhone's Next Chapter          │
│  John Gruber shares his thoughts    │
│  on what's coming next for...       │
└─────────────────────────────────────┘
```

**时间线控制按钮**：
```
┌─────────────────────────────────────┐
│  ← Home                    12 ▾    │  ← 右上角新内容计数按钮
├─────────────────────────────────────┤
│                                     │
│  点击 "12 ▾" 弹出菜单：             │
│  ┌─────────────────────┐           │
│  │ 📍 Timeline Position │           │  ← 跳转到保存的位置
│  │ 📅 Today             │           │  ← 跳转到最近 24h 的最早内容
│  │ ⬆️ Top               │           │  ← 跳转到最新内容
│  └─────────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

**滑动操作**：
```
← 左滑                                右滑 →
┌──────────┬─────────────────┬──────────┐
│  Share   │  Article Item   │  Later   │
│   📤     │                 │   ⏰     │
└──────────┴─────────────────┴──────────┘
```

---

#### 4.3.3 文章详情页 (Article Detail)

**功能说明**：展示文章的完整内容，是用户花费最多时间的页面。

**布局设计**：
```
┌─────────────────────────────────────┐
│  ← Back                    ⋯       │  ← 导航栏（滚动时可隐藏）
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │       Hero Image            │   │  ← 头图（如果有，全宽展示）
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  Apple Announces the               │  ← 标题（24pt, Bold）
│  All-New MacBook Pro                │
│                                     │
│  🔵 The Verge                       │  ← 来源（带图标）
│  April 9, 2026 · 8 min read        │  ← 日期 + 预估阅读时间
│                                     │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │  ← 分隔线
│                                     │
│  Apple today unveiled its most      │  ← 正文内容
│  powerful laptop ever, featuring    │     （16pt, Regular, 1.6 行高）
│  the groundbreaking M5 chip that    │
│  delivers unprecedented...          │
│                                     │
│  ## Performance                     │  ← 二级标题
│                                     │
│  The M5 chip represents a           │
│  generational leap in...            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │  ← 内嵌图片（可点击放大）
│  │       Inline Image          │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│  Caption text for the image        │  ← 图片说明（小字灰色）
│                                     │
│  > "This is the fastest Mac        │  ← 引用块
│  > we've ever made"                │
│  > — Tim Cook                      │
│                                     │
│  ```                               │  ← 代码块
│  const result = await fetch()      │
│  ```                               │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ⏰    🔖    ❤️    📤    🌐        │  ← 底部操作栏
│ Later Book  Fav  Share Browser     │     固定在底部
│                                     │
└─────────────────────────────────────┘
```

**底部操作栏详细说明**：

| 图标 | 功能 | 交互 |
|------|------|------|
| ⏰ | Later（稍后阅读） | 点击切换，激活时高亮 |
| 🔖 | Bookmark（书签） | 点击切换，激活时高亮 |
| ❤️ | Favorite（收藏） | 点击切换，激活时高亮 |
| 📤 | Share（分享） | 调用系统分享面板 |
| 🌐 | Open in Browser | 在外部浏览器中打开 |

---

#### 4.3.4 Reader View（去杂阅读模式）

**功能说明**：提取网页正文，去除广告和导航元素，提供纯净的阅读体验。

```
┌─────────────────────────────────────┐
│  ← Back    📖 Reader View    Aa    │  ← Aa 按钮调出排版设置
├─────────────────────────────────────┤
│                                     │
│         ┌───────────────┐           │
│         │               │           │
│         │  Article      │           │  ← 内容区域有最大宽度限制
│         │  Content      │           │     （手机全宽，平板居中）
│         │  Here...      │           │
│         │               │           │
│         └───────────────┘           │
│                                     │
└─────────────────────────────────────┘

排版设置面板：
┌─────────────────────────────────────┐
│  Text Size     A─────●───────A     │  ← 字号滑块
│  Line Height   ≡─────●───────≡     │  ← 行高滑块
│  Max Width     ├─────●───────┤     │  ← 内容宽度（仅平板）
│                                     │
│  Bionic Reading          [  OFF  ]  │  ← Bionic Reading 开关
│                                     │
│  Serif / Sans-serif      [Sans  ]  │  ← 字体选择
└─────────────────────────────────────┘
```

---

#### 4.3.5 播客播放器

**迷你播放器**（固定在底部）：
```
┌─────────────────────────────────────┐
│  🎵 ▶️ Episode Title - Podcast  ●── │  ← 迷你播放器条
└─────────────────────────────────────┘
```

**展开播放器**：
```
┌─────────────────────────────────────┐
│  ▾ Minimize                         │
├─────────────────────────────────────┤
│                                     │
│         ┌───────────────┐           │
│         │               │           │
│         │   Podcast     │           │  ← 播客封面（大图）
│         │   Artwork     │           │
│         │               │           │
│         └───────────────┘           │
│                                     │
│  Episode Title                      │  ← 集数标题
│  Podcast Name                       │  ← 播客名称
│                                     │
│  12:34 ────●──────────── 45:00     │  ← 进度条 + 时间
│                                     │
│       ⏪15   ▶️    ⏩30             │  ← 播放控制
│                                     │
│  1.0x          🔊 ────●──          │  ← 倍速 + 音量
│                                     │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
│                                     │
│  Chapters                           │  ← 章节列表（如果有）
│  ├ 00:00  Introduction              │
│  ├ 05:30  Topic 1                   │
│  └ 25:00  Wrap Up                   │
│                                     │
└─────────────────────────────────────┘
```

---

#### 4.3.6 设置页

```
┌─────────────────────────────────────┐
│  ← Back        Settings            │
├─────────────────────────────────────┤
│                                     │
│  GENERAL                            │
│  ┌─────────────────────────────┐   │
│  │ Timelines                 → │   │  ← 时间线设置
│  │ Default Viewers           → │   │  ← 默认查看器
│  │ Default Apps              → │   │  ← 默认应用
│  └─────────────────────────────┘   │
│                                     │
│  DISPLAY & LAYOUT                   │
│  ┌─────────────────────────────┐   │
│  │ Theme              System → │   │  ← 主题选择
│  │ App Icon          Default → │   │  ← 应用图标
│  │ Avatar Style      Circle → │   │  ← 头像样式
│  │ Show Avatars         [ON]   │   │  ← 显示头像开关
│  │ Show Folder Icons    [OFF]  │   │  ← 文件夹图标开关
│  └─────────────────────────────┘   │
│                                     │
│  READING                            │
│  ┌─────────────────────────────┐   │
│  │ Text Size         Medium → │   │
│  │ Line Height       Normal → │   │
│  │ Max Width         Default → │   │  ← 仅平板
│  │ Bionic Reading      [OFF]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  YOUR DATA                          │
│  ┌─────────────────────────────┐   │
│  │ Export OPML              → │   │
│  │ Import OPML              → │   │
│  │ Diagnostics              → │   │
│  └─────────────────────────────┘   │
│                                     │
│  ABOUT                              │
│  ┌─────────────────────────────┐   │
│  │ Version            1.0.0    │   │
│  │ Privacy Policy           → │   │
│  │ Acknowledgements        → │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

### 4.4 主题与配色

#### 亮色主题 (Light)

| 元素 | 颜色 | 色值 |
|------|------|------|
| 背景色 | 白色 | `#FFFFFF` |
| 二级背景 | 浅灰 | `#F2F2F7` |
| 主文字 | 深黑 | `#1C1C1E` |
| 二级文字 | 灰色 | `#8E8E93` |
| 强调色 | 蓝色 | `#007AFF` |
| 分隔线 | 浅灰 | `#E5E5EA` |
| 卡片背景 | 白色 | `#FFFFFF` |

#### 暗色主题 (Dark)

| 元素 | 颜色 | 色值 |
|------|------|------|
| 背景色 | 深灰 | `#1C1C1E` |
| 二级背景 | 更深灰 | `#2C2C2E` |
| 主文字 | 白色 | `#FFFFFF` |
| 二级文字 | 灰色 | `#8E8E93` |
| 强调色 | 蓝色 | `#0A84FF` |
| 分隔线 | 深灰 | `#38383A` |
| 卡片背景 | 深灰 | `#2C2C2E` |

#### OLED 黑色主题 (OLED Black)

| 元素 | 颜色 | 色值 |
|------|------|------|
| 背景色 | 纯黑 | `#000000` |
| 二级背景 | 极深灰 | `#1C1C1E` |
| 主文字 | 白色 | `#FFFFFF` |
| 分隔线 | 深灰 | `#2C2C2E` |

#### Dark Light 混合主题

| 元素 | 颜色 |
|------|------|
| 列表区域 | 使用暗色主题配色 |
| 内容查看器 | 使用亮色主题配色 |

### 4.5 字体规范

| 用途 | 字体 | 字号 | 字重 |
|------|------|------|------|
| 大标题 | System (SF Pro Display) | 28pt | Bold |
| 文章标题 | System | 20pt | Semibold |
| 列表标题 | System | 17pt | Semibold |
| 正文 | System | 16pt | Regular |
| 摘要 | System | 14pt | Regular |
| 辅助信息 | System | 12pt | Regular |
| Section Header | System | 13pt | Semibold, 大写 |

> **Flutter 实现**：使用系统默认字体，iOS 上自动使用 SF Pro，Android 上使用 Roboto。

### 4.6 动画与转场规范

| 场景 | 动画类型 | 时长 | 曲线 |
|------|----------|------|------|
| 页面推入 | 右滑入 (iOS style) | 350ms | `Curves.easeInOut` |
| 页面返回 | 左滑出 + 手势驱动 | 跟随手势 | `Curves.easeInOut` |
| 列表项出现 | 淡入 + 微上移 | 200ms | `Curves.easeOut` |
| 滑动操作 | 跟随手势平移 | 跟随手势 | Linear |
| 主题切换 | 全局淡入淡出 | 300ms | `Curves.easeInOut` |
| 下拉刷新 | 弹性回弹 | 500ms | `Curves.elasticOut` |
| 图片放大 | Hero 动画 | 300ms | `Curves.easeInOut` |
| 迷你播放器展开 | 底部滑入 + 缩放 | 400ms | `Curves.easeInOut` |

### 4.7 手势交互规范

| 手势 | 位置 | 功能 |
|------|------|------|
| **下拉** | 文章列表 | 刷新订阅源 |
| **左滑列表项** | 文章列表 | 触发快捷操作（分享等） |
| **右滑列表项** | 文章列表 | 触发快捷操作（Later 等） |
| **左滑页面** | 文章详情 | 加载下一篇（更新的）文章 |
| **右滑页面** | 文章详情 | 返回列表（iOS 风格边缘手势） |
| **双指缩放** | 图片查看器 | 放大/缩小图片 |
| **长按** | 源列表项 | 弹出上下文菜单 |
| **长按** | 文章中的链接 | 预览链接 |
| **点击状态栏** | 任意页面 | 跳转到保存的时间线位置 |

---

## 五、技术架构

### 5.1 技术选型

| 层级 | 技术方案 | 说明 |
|------|----------|------|
| **框架** | Flutter 3.x | 跨平台 UI 框架 |
| **语言** | Dart | Flutter 原生语言 |
| **状态管理** | Riverpod 2.x | 响应式状态管理，支持代码生成 |
| **路由** | go_router | 声明式路由，支持深度链接 |
| **本地数据库** | Isar / Drift (SQLite) | 高性能本地存储 |
| **网络请求** | Dio | HTTP 客户端，支持拦截器 |
| **RSS 解析** | webfeed / 自研 | RSS/Atom/JSON Feed 解析 |
| **HTML 渲染** | flutter_widget_from_html | 富文本 HTML 渲染 |
| **WebView** | flutter_inappwebview | 应用内浏览器 |
| **音频播放** | just_audio | 播客播放 |
| **视频播放** | video_player / chewie | 视频播放 |
| **图片缓存** | cached_network_image | 图片加载与缓存 |
| **云同步** | Firebase / Supabase | 可选的云端同步 |
| **本地通知** | flutter_local_notifications | 新内容通知 |
| **国际化** | flutter_localizations | 多语言支持 |

### 5.2 项目结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # App 根组件
│
├── core/                              # 核心基础层
│   ├── constants/                     # 常量定义
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_dimensions.dart
│   │   └── app_durations.dart
│   ├── theme/                         # 主题系统
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   ├── dark_theme.dart
│   │   └── oled_theme.dart
│   ├── router/                        # 路由配置
│   │   └── app_router.dart
│   ├── network/                       # 网络层
│   │   ├── dio_client.dart
│   │   └── api_interceptor.dart
│   ├── database/                      # 数据库
│   │   ├── app_database.dart
│   │   └── migrations/
│   ├── utils/                         # 工具类
│   │   ├── date_formatter.dart
│   │   ├── html_parser.dart
│   │   ├── opml_parser.dart
│   │   ├── feed_discoverer.dart
│   │   └── bionic_reading.dart
│   └── extensions/                    # Dart 扩展
│       ├── string_ext.dart
│       └── datetime_ext.dart
│
├── data/                              # 数据层
│   ├── models/                        # 数据模型
│   │   ├── feed.dart                  # 订阅源
│   │   ├── feed_item.dart             # 内容项
│   │   ├── folder.dart                # 文件夹
│   │   ├── tag.dart                   # 标签
│   │   ├── filter.dart                # 过滤器
│   │   ├── scroll_position.dart       # 滚动位置
│   │   └── app_settings.dart          # 应用设置
│   ├── repositories/                  # 数据仓库
│   │   ├── feed_repository.dart
│   │   ├── article_repository.dart
│   │   ├── tag_repository.dart
│   │   ├── settings_repository.dart
│   │   └── sync_repository.dart
│   ├── datasources/                   # 数据源
│   │   ├── local/                     # 本地数据源
│   │   │   ├── feed_local_ds.dart
│   │   │   ├── article_local_ds.dart
│   │   │   └── settings_local_ds.dart
│   │   └── remote/                    # 远程数据源
│   │       ├── rss_remote_ds.dart
│   │       ├── feedbin_remote_ds.dart
│   │       └── feedly_remote_ds.dart
│   └── services/                      # 业务服务
│       ├── feed_refresh_service.dart
│       ├── feed_discovery_service.dart
│       ├── reader_view_service.dart
│       ├── sync_service.dart
│       └── podcast_service.dart
│
├── features/                          # 功能模块（按页面组织）
│   ├── source_list/                   # 源列表
│   │   ├── source_list_page.dart
│   │   ├── source_list_controller.dart
│   │   └── widgets/
│   │       ├── source_section.dart
│   │       ├── source_item.dart
│   │       └── add_feed_dialog.dart
│   │
│   ├── article_list/                  # 文章列表
│   │   ├── article_list_page.dart
│   │   ├── article_list_controller.dart
│   │   └── widgets/
│   │       ├── article_list_item.dart
│   │       ├── article_list_item_compact.dart
│   │       ├── timeline_control_button.dart
│   │       └── swipe_action_widget.dart
│   │
│   ├── article_detail/                # 文章详情
│   │   ├── article_detail_page.dart
│   │   ├── article_detail_controller.dart
│   │   └── widgets/
│   │       ├── article_content_view.dart
│   │       ├── article_action_bar.dart
│   │       ├── article_header.dart
│   │       └── reader_view.dart
│   │
│   ├── image_viewer/                  # 图片查看器
│   │   └── image_viewer_page.dart
│   │
│   ├── podcast_player/                # 播客播放器
│   │   ├── mini_player.dart
│   │   ├── full_player_page.dart
│   │   └── podcast_controller.dart
│   │
│   ├── video_player/                  # 视频播放器
│   │   └── video_player_page.dart
│   │
│   ├── browser/                       # 应用内浏览器
│   │   └── in_app_browser_page.dart
│   │
│   ├── search/                        # 搜索
│   │   ├── search_page.dart
│   │   └── search_controller.dart
│   │
│   ├── filter/                        # 过滤器
│   │   ├── filter_editor_page.dart
│   │   └── filter_controller.dart
│   │
│   └── settings/                      # 设置
│       ├── settings_page.dart
│       ├── theme_settings_page.dart
│       ├── reading_settings_page.dart
│       ├── timeline_settings_page.dart
│       ├── data_settings_page.dart
│       └── about_page.dart
│
└── shared/                            # 共享组件
    ├── widgets/                       # 通用 Widget
    │   ├── adaptive_scaffold.dart     # 自适应布局（手机/平板）
    │   ├── feed_icon.dart             # 订阅源图标
    │   ├── shimmer_loading.dart       # 骨架屏加载
    │   ├── empty_state.dart           # 空状态
    │   ├── error_state.dart           # 错误状态
    │   ├── context_menu.dart          # 上下文菜单
    │   └── pull_to_refresh.dart       # 下拉刷新
    └── providers/                     # 全局 Provider
        ├── theme_provider.dart
        ├── settings_provider.dart
        └── connectivity_provider.dart
```

### 5.3 数据模型

```dart
// Feed - 订阅源
class Feed {
  String id;
  String title;
  String? description;
  String feedUrl;         // RSS/Atom/JSON Feed URL
  String? siteUrl;        // 网站 URL
  String? iconUrl;        // favicon URL
  FeedType type;          // blog / podcast / youtube / mastodon / bluesky
  String? folderId;       // 所属文件夹
  String? groupId;        // 自动分组 ID
  DateTime? lastFetched;  // 最后刷新时间
  int fetchDurationMs;    // 刷新耗时（诊断用）
  ViewerType defaultViewer; // 默认查看器
  bool autoReaderView;    // 自动 Reader View
  DateTime createdAt;
}

// FeedItem - 内容项
class FeedItem {
  String id;
  String feedId;
  String title;
  String? summary;        // 摘要
  String? content;        // HTML 内容
  String? url;            // 原始链接
  String? imageUrl;       // 缩略图
  List<String>? imageUrls; // 多图
  String? audioUrl;       // 音频链接（播客）
  String? videoUrl;       // 视频链接
  int? audioDuration;     // 音频时长（秒）
  String? author;
  DateTime publishedAt;
  DateTime fetchedAt;
  ContentType contentType; // article / image / video / audio / social
  Map<String, dynamic>? metadata; // 额外元数据
}

// Tag - 标签
class Tag {
  String id;
  String name;
  String? iconName;       // 自定义图标
  bool isBuiltIn;         // 是否内置标签（Later/Bookmarks/Favorites）
  bool isShared;          // 是否公开共享
  String? sharedFeedUrl;  // 共享 Feed URL
  int itemCount;
  DateTime createdAt;
}

// TaggedItem - 标签关联
class TaggedItem {
  String tagId;
  String itemId;
  DateTime taggedAt;
}

// Folder - 文件夹
class Folder {
  String id;
  String name;
  String? iconName;
  int sortOrder;
  DateTime createdAt;
}

// Filter - 过滤器
class Filter {
  String id;
  String name;
  List<String> includeKeywords;
  List<String> excludeKeywords;
  List<ContentType>? mediaTypes;
  List<FeedType>? feedTypes;
  bool matchWholeWord;
  DateTime createdAt;
}

// ScrollPosition - 滚动位置
class ScrollPosition {
  String timelineId;      // feed/folder/tag/filter 的 ID
  String? lastItemId;     // 最后阅读的 item ID
  double scrollOffset;    // 精确滚动偏移
  DateTime savedAt;
}

// 枚举
enum FeedType { blog, podcast, youtube, mastodon, bluesky, reddit, other }
enum ContentType { article, image, video, audio, social }
enum ViewerType { viewer, readerView, inAppBrowser }
```

### 5.4 核心流程

#### 订阅源刷新流程

```
用户下拉刷新 / 定时触发
        │
        ▼
┌─────────────────┐
│ 获取所有订阅源    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ 并发请求所有 Feed │────→│ 解析 RSS/Atom/   │
│ （限制并发数）    │     │ JSON Feed        │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│ 对比本地数据      │     │ 处理新增/更新项   │
│ 去重             │     │ 保持发布时间排序   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│ 批量写入数据库    │     │ 更新 UI          │
│                 │     │ （刷新完成后）     │
└─────────────────┘     └─────────────────┘
```

#### 滚动位置同步流程

```
用户滚动列表
     │
     ▼
┌──────────────────┐
│ 防抖处理（500ms）│ 防抖处理（500ms） │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 计算当前可见的    │
│ 最后一个 Item ID  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 保存到本地数据库  │
│ (timeline_id +   │
│  item_id +       │
│  scroll_offset)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 上传到云端同步    │  ← 仅同步 timeline_id + item_id
│ （如果已启用）    │
└──────────────────┘

恢复位置：
┌──────────────────┐
│ 打开时间线        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 查询本地/云端     │
│ 保存的位置        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 定位到对应 Item   │
│ 恢复 scrollOffset │
└──────────────────┘
```

---

## 六、非功能需求

### 6.1 性能要求

| 指标 | 目标值 | 说明 |
|------|--------|------|
| **冷启动时间** | < 2s | 从点击图标到首屏可交互 |
| **列表滚动帧率** | 60fps | 列表滚动无卡顿 |
| **Feed 刷新时间** | < 10s（50 个源） | 并发刷新，限制并发数为 10 |
| **文章加载时间** | < 500ms | 从点击到内容完整展示 |
| **Reader View 提取** | < 3s | 从触发到内容展示 |
| **内存占用** | < 200MB | 正常使用场景 |
| **数据库查询** | < 50ms | 单次查询响应时间 |
| **动画流畅度** | 60fps | 所有动画无掉帧 |

### 6.2 兼容性要求

| 平台 | 最低版本 |
|------|----------|
| **iOS** | iOS 15.0+ |
| **Android** | Android 8.0 (API 26)+ |
| **Flutter SDK** | 3.19+ |
| **Dart SDK** | 3.3+ |

### 6.3 可用性要求

| 需求 | 说明 |
|------|------|
| **离线使用** | 已缓存的内容在无网络时可正常阅读 |
| **无障碍** | 支持 VoiceOver/TalkBack 屏幕阅读器 |
| **动态字体** | 支持系统级字体大小调整 |
| **横竖屏** | 手机支持竖屏，平板支持横竖屏自适应 |
| **深色模式** | 跟随系统或手动切换 |

### 6.4 安全与隐私

| 需求 | 说明 |
|------|------|
| **零数据收集** | 不收集任何用户数据、使用数据或个人信息 |
| **本地存储加密** | 敏感数据（如第三方服务密码）使用平台 Keychain/Keystore 存储 |
| **HTTPS** | 所有网络请求强制使用 HTTPS |
| **云端数据** | 同步数据存储在用户自己的云账户中 |

---

## 七、开发里程碑

### Phase 1：MVP（核心阅读体验）— 6 周

| 周次 | 任务 | 交付物 |
|------|------|--------|
| W1-2 | 项目搭建 + 数据层 | Flutter 项目框架、数据库、RSS 解析器 |
| W3 | 订阅管理 | 添加/删除订阅、OPML 导入导出、Feed 发现 |
| W4 | 文章列表 + 时间线 | 统一时间线、分类浏览、下拉刷新、列表项 UI |
| W5 | 文章详情 + 阅读 | 文章查看器、Reader View、应用内浏览器 |
| W6 | 主题 + 基础设置 | 亮/暗/OLED 主题、字号行高设置、基础设置页 |

**MVP 交付标准**：
- ✅ 可添加 RSS 订阅并浏览内容
- ✅ 统一时间线按时间排序
- ✅ 文章详情页支持富文本渲染
- ✅ Reader View 去杂阅读
- ✅ 亮色/暗色主题切换
- ✅ OPML 导入/导出

### Phase 2：内容组织（标签与过滤）— 4 周

| 周次 | 任务 | 交付物 |
|------|------|--------|
| W7 | 标签系统 | Later/Bookmarks/Favorites + 自定义标签 |
| W8 | 滑动操作 + 手势 | 列表滑动操作、详情页左滑导航、手势返回 |
| W9 | 过滤器 + 文件夹 | 自定义过滤器、自定义文件夹 |
| W10 | 搜索 + 滚动位置 | 全文搜索、滚动位置记忆与恢复 |

### Phase 3：多媒体支持 — 3 周

| 周次 | 任务 | 交付物 |
|------|------|--------|
| W11 | 图片查看器 | 全屏图片查看、缩放、多图切换 |
| W12 | 播客播放器 | 音频播放、迷你播放器、章节标记 |
| W13 | 视频播放器 | 内嵌视频播放、YouTube 支持 |

### Phase 4：同步与服务集成 — 4 周

| 周次 | 任务 | 交付物 |
|------|------|--------|
| W14 | 云端同步 | 订阅/位置/标签的云端同步 |
| W15 | 自建服务集成 | Google Reader API 抽象层、Reader/FreshRSS 集成 |
| W16 | 第三方服务 | Feedbin/Feedly/Inoreader 集成 |
| W17 | 高级功能 | Bionic Reading、共享订阅源、Widget |

### Phase 5：打磨与发布 — 2 周

| 周次 | 任务 | 交付物 |
|------|------|--------|
| W18 | 动画打磨 + 性能优化 | 流畅的转场动画、列表性能优化 |
| W19 | 测试 + 发布准备 | 全面测试、应用商店素材、发布 |

---

## 八、关键交互细节（Reeder 原版还原要点）

### 8.1 列表滚动体验

- **刷新策略**：下拉刷新时，等待所有 feed 刷新完成后才显示新内容，避免滚动位置跳动
- **位置记忆**：每个时间线（Home/文件夹/标签/过滤器/单源）独立记忆滚动位置
- **新内容提示**：右上角显示新内容数量，点击可选择跳转方式
- **状态栏点击**：iOS 上点击状态栏默认跳转到保存的时间线位置（而非顶部）

### 8.2 内容查看器智能选择

根据内容类型自动选择最佳查看器：

| 内容类型 | 默认查看器 | 可选查看器 |
|----------|-----------|-----------|
| 博客文章 | Article Viewer | Reader View / In-App Browser |
| 图片帖子 | Image Viewer | Article Viewer |
| 视频 | Video Player | In-App Browser |
| 播客 | Podcast Player | — |
| 社交帖子 | Thread Viewer | In-App Browser |
| 保存的链接 | In-App Browser | Reader View |

### 8.3 标签系统交互

- **快捷操作**：工具栏一键切换 Later/Bookmarks/Favorites
- **滑动标记**：列表中左滑/右滑快速标记
- **自定义图标**：内置标签和自定义标签都可设置自定义图标和名称
- **标签计数**：可选在源列表中显示标签项数

### 8.4 iPad 自适应布局

- **横屏**：三栏布局（源列表 + 文章列表 + 文章详情）
- **竖屏**：两栏布局（文章列表 + 文章详情），源列表可侧滑呼出
- **iPad mini 竖屏**：默认使用全屏详情视图（可在设置中切换）
- **列宽可调**：拖拽列分隔线调整各栏宽度

### 8.5 键盘快捷键（平板外接键盘）

| 快捷键 | 功能 |
|--------|------|
| `J` | 下一篇（更旧的）文章 |
| `K` | 上一篇（更新的）文章 |
| `O` | 在默认应用/浏览器中打开 |
| `L` | 切换 Later |
| `B` | 切换 Bookmarks |
| `F` | 切换 Favorites |
| `S` | 跳转到保存的时间线位置 |
| `D` | 跳转到今天 |
| `A` | 跳转到顶部 |
| `Space` | 滚动详情页 / 切换播放 |
| `Shift+Space` | 向上滚动详情页 |

---

## 九、风险与应对

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| RSS 解析兼容性 | 部分非标准 feed 无法解析 | 使用成熟的解析库 + 容错处理 + 诊断工具 |
| Reader View 提取质量 | 部分网页正文提取不准确 | 集成 Readability 算法 + 提供回退到浏览器的选项 |
| 大量订阅源性能 | 100+ 订阅源刷新慢 | 并发控制 + 增量刷新 + 后台刷新 |
| 跨平台 UI 一致性 | iOS/Android 体验差异 | 使用 Cupertino 风格为主 + 平台适配层 |
| 云同步冲突 | 多设备同时操作导致数据冲突 | Last-write-wins 策略 + 仅同步关键数据 |
| 第三方 API 变更 | Feedbin/Feedly 等 API 变更 | 抽象服务层 + 版本化 API 调用 |

---

## 十、成功指标

| 指标 | 目标 | 衡量方式 |
|------|------|----------|
| **日活跃用户** | MVP 后 3 个月达到 1000 DAU | 匿名统计（可选开启） |
| **用户留存率** | 7 日留存 > 40% | — |
| **应用评分** | App Store / Google Play > 4.5 | 商店评分 |
| **崩溃率** | < 0.1% | Crashlytics |
| **平均阅读时长** | > 15 分钟/天 | 本地统计（不上传） |
| **订阅源数量** | 平均每用户 > 20 个 | 本地统计 |

---

## 附录

### A. URL Scheme

| URL | 功能 |
|-----|------|
| `reed://` | 打开应用 |
| `reed://feed-url.com` | 打开应用并搜索指定 URL 的 feed |

### B. 支持的 Feed 格式

| 格式 | 版本 | 说明 |
|------|------|------|
| RSS | 2.0 | 最广泛使用的 RSS 格式 |
| Atom | 1.0 | 标准化的 feed 格式 |
| JSON Feed | 1.1 | 基于 JSON 的现代 feed 格式 |

### C. 第三方服务集成（P1）

| 服务 | 类型 | 优先级 |
|------|------|--------|
| Feedbin | RSS 同步 | 高 |
| Feedly | RSS 同步 | 高 |
| Inoreader | RSS 同步 | 中 |
| NewsBlur | RSS 同步 | 低 |
| The Old Reader | RSS 同步 | 低 |

### C2. 自建服务集成（P1）

| 服务 | 协议/API | 优先级 |
|------|----------|--------|
| FreshRSS | fressrss.org API | 中 |
| Reader | Google Reader API | 高 |

### D. 参考资源

- **Reeder 官网**：`https://reederapp.com/`
- **Reeder Classic**：`https://reederapp.com/classic/`
- **Reeder Help**：`https://reederapp.com/help/`
- **App Store**：`https://apps.apple.com/us/app/reeder/id6475002485`
- **RSS 2.0 规范**：`https://www.rssboard.org/rss-specification`
- **Atom 规范**：`https://tools.ietf.org/html/rfc4287`
- **JSON Feed 规范**：`https://www.jsonfeed.org/version/1.1/`
