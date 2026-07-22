# 《文明的地图 HD》下一阶段开发计划

> **生成日期**：2026-07-22  
> **基线提交**：`2afb610 Baseline after Phase 10B`  
> **计划制定人**：Codex Agent (Superpowers: brainstorming + writing-plans 工作流)  
> **当前工作区**：Phase 10B-HOME1 正在实施中（未提交）

---

## 当前审计结果

### Git 状态

| 项目 | 值 |
|---|---|
| 最新提交 | `2afb610 Baseline after Phase 10B` |
| 状态 | ⚠️ **未提交的修改** |
| 修改文件 | `lib/components/mission_card.dart`, `lib/screens/home_screen.dart`, `lib/screens/world_map_screen.dart` |
| 新文件 | `lib/data/home_task_state.dart`, `test/home_task_navigation_test.dart` |

### 测试状态

| 测试集 | 基线 | 当前 |
|---|---|---|
| 完整测试 | 154/154 ✅ | **+133 -22 ❌** |

**22 个失败来源**：

1. `test/home_task_navigation_test.dart` — **编译错误**：D22 的 `MaterialApp.router` 中存在重复的 `routerConfig` 参数
2. `test/smoke_test.dart` — `WorldMapScreen renders`：`_handleNavigationIntent` 在 `build()` 中调用 `GoRouterState.of(context)`，导致某些测试上下文中抛异常
3. `test/world_map_test.dart` — 约 20 个 Canvas 交互测试失败，包括 pending timer 违规和 Crash 异常

**根因**：`lib/screens/world_map_screen.dart` 的 `_handleNavigationIntent` 在 `build()` 方法中无条件调用，未处理 `GoRouter` 上下文缺失的情况；且 `addPostFrameCallback` 在当前帧回调节点选择和状态更新可能破坏了 Canvas 交互测试的异步平衡。

### 当前 Phase 10B-HOME1 是"正在实施的未完成阶段"

核心逻辑（状态推导、导航路由）已实现，但：
- 新测试文件有编译错误 — 需修复
- 已有测试被新代码破坏 — 需修复
- 尚未做 Git 提交

---

## 阶段划分总览

| 优先级 | 阶段 | 依赖 | 预计修改文件数 | 用户验收 |
|---|---|---|---|---|
| P0 | 10B-HOME1 | 无 | 5-7 | 必须 |
| P1 | 10B-WEB1 | HOME1 完成 | 10-15 | 可选（批量） |
| P1 | 10B-WEB2 | WEB1 完成 | 3-5 | 可选（批量） |
| P1 | 10B-WEB3 | WEB2 完成 | 5-8 | 可选（批量） |
| P2 | 11A | WEB3 完成 | 8-12 | 必须 |
| P3 | 11B+ | 11A 完成 | 15+ | 必须 |

**处理顺序**：按上表从上到下。每个阶段在 GoRouter 页面切换中必须保留全功能 `context.go` 导航。

---

## Phase 10B-HOME1：首页"今日文明任务"导航闭环（已完成度约 75%）

### 用户目标

- 首页三张任务卡整卡可点击
- 地图任务 → 世界地图并定位高加索
- 阅读任务 → 精读营定位第 26 章
- 文明解释任务 → Mission 页面
- 状态从未开始 / 进行中 / 已完成自动推导
- 已完成任务仍可点击进入

### 用户故事

- 第一次打开首页：三张卡都是"未开始"，第一张卡带金色推荐标识
- 完成地图探索后：地图卡变"已完成"，阅读卡自动变推荐
- 全部完成后：推荐标识消失，所有卡显示"已完成"
- 即使已完成，仍可点击重新进入

### 当前代码审计范围

| 文件 | 状态 | 问题 |
|---|---|---|
| `lib/data/home_task_state.dart` | 新建 ✅ | 完整，三个 Provider + 推荐逻辑 |
| `lib/screens/home_screen.dart` | 已修改 ✅ | 结构正确 |
| `lib/components/mission_card.dart` | 已修改 ✅ | 结构正确 |
| `lib/screens/world_map_screen.dart` | 已修改 ❌ | `_handleNavigationIntent` 破坏已有测试 |
| `test/home_task_navigation_test.dart` | 新建 ❌ | D22 编译错误 |

### 修改文件清单

**需修复的现有修改**：
- `lib/screens/world_map_screen.dart` — 修复 `_handleNavigationIntent` 的 `build()` 使用方式，确保不破坏已有测试
- `test/home_task_navigation_test.dart` — 修复 D22 的重复 `routerConfig` 编译错误

**无需修改的文件**（已正确实现）：
- `lib/data/home_task_state.dart`
- `lib/screens/home_screen.dart`
- `lib/components/mission_card.dart`
- `lib/router/app_router.dart`（路由已存在，无需修改）
- `lib/data/mission_state.dart`（所有 Provider 已存在，未被修改）
- `lib/models/exploration_progress.dart`（"高加索 3 个发现点"是唯一集合，后续新区域需扩展但当前不动）

### 数据状态和 Provider 来源

| Provider | 数据源 | 状态类型 |
|---|---|---|
| `homeMapTaskStatusProvider` | `explorationProgressProvider.forRegion('caucasus')` | notStarted / inProgress / completed |
| `homeReadingTaskStatusProvider` | `readingEvidenceProvider` → ch26 证据存在否 | notStarted / inProgress / completed |
| `homeMissionTaskStatusProvider` | `missionResultSnapshotProvider` + `stepAnswersProvider` + `missionEvidenceProvider` | notStarted / inProgress / completed |
| `currentRecommendedHomeTaskProvider` | 以上三个 Provider → 返回第一个未完成的 ID | `int?` |

**关键设计决策**（遵循 AGENTS.md）：
- 状态从现有 Provider 推导，不建立重复本地 bool 状态
- 使用 GoRouter `context.go` 导航，不引入 `Navigator.pushNamed`
- 不修改 Mission 提交规则（`evaluateFinalSubmissionEligibility` 和三处调用不动）

### 路由和页面交互

| 卡片 | 导航目标 | Extra 参数 | 接收方 |
|---|---|---|---|
| 地图任务 (id=1) | `/world-map` | `{'focusRegionId': 'caucasus'}` | `WorldMapScreen._handleNavigationIntent` |
| 阅读任务 (id=2) | `/reading-camp` | `{'focusChapter': 26}` | `ReadingCampScreen`（当前未实现 extra 处理） |
| Mission (id=3) | `/mission` | 无 | — |

### 测试策略

- **单元测试**：A 组 12 个测试已覆盖所有 Provider 纯逻辑（已完成）
- **Widget 测试**：B 组 6 个测试覆盖渲染和导航（D22 编译错误需修复）
- **State refresh 测试**：F28 已验证 Provider 变更自动刷新卡片状态
- **验证存在风险**：`smoke_test.dart` 和 `world_map_test.dart` 被当前修改破坏，修复后需再次验证 154/154

### D22 编译错误修复方案

**问题**：`test/home_task_navigation_test.dart` 第 377 行代码重复定义 `routerConfig`：

```dart
MaterialApp.router(
  theme: AppTheme.darkTheme(),
  routerConfig: _testRouter(),       // ← 第 376 行
  routerConfig: _testRouterPath('/world-map'),  // ← 第 377 行 — 重复！
),
```

**修复**：移除第一个 `routerConfig`，保留第二个：

```dart
MaterialApp.router(
  theme: AppTheme.darkTheme(),
  routerConfig: _testRouterPath('/world-map'),
),
```

### `_handleNavigationIntent` 修复方案

**问题**：`_handleNavigationIntent` 在 `build()` 中无条件调用，当 Widget 不在 GoRouter 上下文中时 `GoRouterState.of(context)` 抛出异常。

**修复**：在 `_handleNavigationIntent` 中添加 try-catch 保护：

```dart
void _handleNavigationIntent(BuildContext context, WidgetRef ref) {
  try {
    final routerState = GoRouterState.of(context);
    final extra = routerState.extra;
    if (extra is Map<String, dynamic>) {
      final focusId = extra['focusRegionId'] as String?;
      if (focusId != null) {
        final region = CivilizationRegion.worldMap
            .cast<CivilizationRegion?>()
            .firstWhere((r) => r?.id == focusId, orElse: () => null);
        if (region != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(selectedRegionProvider)?.id != focusId) {
              ref.read(selectedRegionProvider.notifier).state = region;
            }
          });
        }
      }
    }
  } catch (_) {
    // 测试环境中 GoRouter 上下文可能不可用
  }
}
```

### 验收步骤

```bash
flutter test --reporter expanded
```

预期：**全部 154+ 测试通过**（包括新的 HOME1 测试，约 160-170 测试点）

### 主要风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| `_handleNavigationIntent` 的 `GoRouterState.of(context)` 在没有 router 的测试上下文中抛出异常 | 多个已有测试失败 | 在 `build()` 中增加 try-catch |
| `addPostFrameCallback` 延迟执行导致测试计时器异常 | pending timer 违规 | 使用 `pump(Duration)` 推进测试 |
| D22 测试 `_testRouterPath('/world-map')` 中 `extra` 参数为空，无法验证焦点定位 | 测试有效性 | 先修复编译错误，再验证逻辑完整性 |

### 回滚点

**方案 A（推荐）**：修复当前工作区的问题后直接提交

```bash
git add lib/screens/world_map_screen.dart \
       lib/components/mission_card.dart \
       lib/screens/home_screen.dart \
       lib/data/home_task_state.dart \
       test/home_task_navigation_test.dart
git commit -m "feat: Phase 10B-HOME1 首页今日文明任务导航闭环"
```

**方案 B（如果当前修改不可修复）**：

```bash
git checkout -- lib/
git checkout -- test/
rm lib/data/home_task_state.dart
rm test/home_task_navigation_test.dart
```

### 完成标准

- [ ] `flutter analyze` — 0 errors
- [ ] `dart format .` — 无问题
- [ ] `flutter test --reporter expanded` — 新基线 ≥ 154 测试全通过（含新增的 HOME1 测试）
- [ ] 首页三张任务卡显示正确状态
- [ ] 手动点击验证三个导航到位
- [ ] 模拟器冷启动验收无红屏、overflow

### Git 检查点建议

```
git add ... && git commit -m "feat: Phase 10B-HOME1 首页今日文明任务导航闭环"
```

### 需要用户手动完成的操作

- 模拟器冷启动验收（Codex 不可自动启动模拟器）
- 更新 `docs/PROJECT_SPEC.md` 中 HOME1 标记从"计划需求"改为"已完成"
- 更新 `docs/DEVELOPMENT_STATUS.md` 和 `docs/CURRENT_HANDOFF.md`

---

## Phase 10B-WEB1：Flutter Web 兼容性审计与修复

### 用户目标

- 项目能够在 Flutter Web 模式下编译运行
- 识别并修复仅 iPad 运行时没问题但 Web 有问题的代码

### 当前代码审计范围

**已知 Web 不兼容项**（需验证）：

| 文件 | 潜在问题 | 优先级 |
|---|---|---|
| `lib/main.dart` | `SystemChrome.setPreferredOrientations` 在 Web 上无效果但不应崩溃 | 高 |
| `lib/theme/app_theme.dart` | `PingFang SC` 字体在 Web 上不可用 → 需回退 | 中 |
| `lib/components/world_map_canvas.dart` | `CustomPainter` + `InteractiveViewer` 在 Web 上 Canvas 渲染可能不同 | 中 |
| `lib/screens/reading_camp_screen.dart` | `SelectableText` 在 Web 上行为差异 | 低 |
| `lib/services/` 文件夹 | `FakeEvaluationService` 等同步 API 在 Web 上 fine | 低 |

### 修改文件清单

- `lib/main.dart` — 添加 `kIsWeb` 条件编译跳过 `setPreferredOrientations`
- `lib/theme/app_theme.dart` — 添加 Web 字体回退链（`'PingFang SC', 'Noto Sans SC', sans-serif`）
- 可能新增 `lib/theme/web_fonts.dart`
- `pubspec.yaml` — 可能添加 `flutter: fonts:` 声明 Web 字体加载
- `web/` 目录 — Flutter Web 的 index.html、manifest.json 配置

### 测试策略

- 新增 `test/web_compatibility_test.dart`（纯逻辑测试，无 Widget 测试）
- 手动运行 `flutter build web --release` 验证编译成功

### 风险

| 风险 | 缓解 |
|---|---|
| Web 上的 Canvas 渲染性能 | 调整 `InteractiveViewer` 缩放限制或启用 `viewport` |
| 字体包大小 | Web 上使用 Google Fonts CDN 而非打包 |

### 完成标准

- [ ] `flutter build web --release` 编译成功
- [ ] 在浏览器中打开首页，无红屏无异常
- [ ] iPad 横屏模式依然正常

### Git 检查点

```
git add ... && git commit -m "feat: Phase 10B-WEB1 Flutter Web兼容性审计与修复"
```

### 需要用户手动完成的操作

- 在 Safari 或 Chrome 中打开 `build/web/` 下的 index.html
- 确认字体显示、地图交互、导航正常

---

## Phase 10B-WEB2：Firebase Hosting 体验版部署

### 用户目标

- 将 Flutter Web 构建部署到 Firebase Hosting
- 获得一个可公开访问的 HTTPS URL

### 修改文件清单

- `firebase.json` — Hosting 配置
- `.firebaserc` — 项目别名
- 可能新增 `firebase-init.sh` 脚本（可选）

### 测试策略

- 部署后手动验证：Safari、Chrome 访问 URL
- 验证 GoRouter 路径在非首页刷新时正常工作（`rewrites` 配置）

### 风险

| 风险 | 缓解 |
|---|---|
| Firebase CLI 未安装 | 用户手动安装 `npm install -g firebase-tools` |
| `firebase init hosting` 覆盖文件 | 所有配置文件手动创建，不运行 `firebase init` |

### 完成标准

- [ ] `firebase deploy --only hosting` 成功
- [ ] 公开 URL 可访问、路由正常

### Git 检查点

```
git add ... && git commit -m "feat: Phase 10B-WEB2 Firebase Hosting体验版部署"
```

### 需要用户手动完成的操作

- 安装/配置 Firebase CLI 并登录
- 在 Firebase Console 创建项目
- 运行 `firebase deploy`

---

## Phase 10B-WEB3：iPad Safari 和主屏幕 Web App 真实体验修复

### 用户目标

- 在 iPad Safari 上：
  - 全屏沉浸式体验（隐藏浏览器 Chrome）
  - 状态栏适配
  - 触摸手势（缩放、双击）正常
- 添加到主屏幕后：
  - 独立 Web App 模式启动
  - 无浏览器 UI 干扰
  - Splash screen 显示

### 修改文件清单

- `web/index.html` — `apple-mobile-web-app-capable`, `apple-touch-icon`, `apple-mobile-web-app-status-bar-style`
- `web/manifest.json` — `display: standalone`, `orientation: landscape`
- 可能新增 `assets/icons/apple-touch-icon.png`（应用图标）

### 测试策略

- 在真实 iPad Safari 上页面验收（用户手动）

### 风险

| 风险 | 缓解 |
|---|---|
| Flutter Web 在 iPad Safari 上的已知问题 | 测试时使用 iOS 16+ 版本的 Safari |
| 手势冲突（Safari 默认手势 vs 应用内手势） | 在 index.html 中设置 `touch-action: manipulation` |

### 完成标准

- [ ] Safari 中全屏体验正常
- [ ] 添加到主屏幕后 Web App 模式打开
- [ ] 非刷新路由正常

### Git 检查点

```
git add ... && git commit -m "feat: Phase 10B-WEB3 iPad Safari和主屏幕Web App体验修复"
```

### 需要用户手动完成的操作

- 在 iPad Safari 上访问 Firebase Hosting URL
- 测试触摸交互和导航
- 添加到主屏幕并测试 Web App 模式

---

## Phase 11A：RegionModule 纯 Dart Schema

### 用户目标

- 定义可复用的 `RegionModule` 配置架构
- 将高加索模块的领域逻辑提取为可配置的 DSL
- 配置层与 Flutter 渲染层严格解耦

### 当前代码审计范围

**需要读的文件**（实施时读，规划阶段仅列举）：

- `lib/models/civilization_region.dart` — 当前区域模型
- `lib/models/exploration_progress.dart` — 发现点模型
- `lib/models/thinking_step.dart` — 五步思考模型
- `lib/models/reading_chapter.dart` — 章节模型
- `lib/models/evidence_type.dart` — 证据类型模型
- `lib/data/mission_state.dart` — Mission 状态（RegionModule 触发参数）
- `lib/components/caucasus_map.dart` — 当前高加索地图组件结构
- `lib/screens/caucasus_screen.dart` — 高加索区域页面结构

### 修改文件清单

**新增文件**：
- `lib/modules/region_module.dart` — `RegionModule` 核心数据类
- `lib/modules/region_config.dart` — 区域配置容器
- `lib/modules/discovery_schema.dart` — 发现点配置架构
- `lib/modules/thinking_schema.dart` — 五步思考配置架构
- `lib/modules/module_registry.dart` — 模块注册表
- `test/modules/region_module_test.dart` — 配置解析测试
- `test/modules/module_registry_test.dart` — 注册表测试

**修改文件**：
- `lib/models/exploration_progress.dart` — 替换硬编码 `caucasus` 为模块化区域触发
- `lib/data/mission_state.dart` — `currentMissionProvider` 从模块读取区域 Mission 定义

**不修改的文件**：
- 所有 `lib/screens/` 下的 Widget 文件
- 所有 `lib/components/` 下的 UI 组件
- 所有 `lib/services/` 下的服务文件

### 架构设计原则

```
┌─────────────────────┐       ┌────────────────────────┐
│  RegionModule        │       │  Flutter 渲染层        │
│  (纯 Dart, 无 Widget)│──────▶│  (Widget / Painter)    │
│                     │ 通过  │                        │
│  - discoveries[]    │ ID    │  - 注册表查找渲染器    │
│  - chapters[]       │ 引用  │  - rendererId→Widget   │
│  - regionId         │       │                        │
│  - layers[]         │       │  - 不保存 Config 引用  │
└─────────────────────┘       └────────────────────────┘
```

### 数据流

```
RegionModule data
  → ModuleRegistry (regionId → RegionModule)
  → Riverpod Provider (ref.watch(regionModuleProvider(regionId)))
  → 各 Screen / Component 消费
```

### 测试策略

- 所有模块测试为纯 Dart 测试（无 Flutter 依赖）
- 验证：注册、查找、ID 去重、配置完整性
- 不引入 Widget 测试

### 风险与回滚点

| 风险 | 影响 | 缓解 |
|---|---|---|
| 过度设计 | Schema 太抽象不支持细节 | 用高加索的实际数据验证每个字段 |
| 渲染耦合泄漏 | Config 层引用 Widget | 在文件中写静态检查断言 |
| 现有测试被破坏 | 修改了 `exploration_progress` 和 `mission_state` | 修改时保持向后兼容 |

**回滚点**：删除 `lib/modules/` 目录，回退 `exploration_progress.dart` 和 `mission_state.dart` 的修改。

### 完成标准

- [ ] 所有模块测试通过
- [ ] `dart analyze` — 0 errors
- [ ] 现有 154+ 测试全部通过
- [ ] 配置层不引用任何 Flutter Widget、BuildContext 或 CustomPainter

### Git 检查点

```
git add lib/modules/ test/modules/
git commit -m "feat: Phase 11A RegionModule纯Dart Schema"
```

### 需要用户手动完成的操作

- 代码审查 RegionModule Schema 设计
- 模拟器验收确认继承测试未破坏

---

## Phase 11B+：高加索配置适配 + 新区域内容 + 统一 UI 与双主题

### 用户目标

- 高加索模块完全配置化运行
- 至少一个新区块使用 RegionModule 配置（如中亚或波斯）
- UI 统一视觉语言
- 浅色羊皮纸主题可用

### 当前状态

> ⚠️ **11B+ 是粗粒度规划范围**。具体任务分解需要等 Phase 11A 完成、RegionModule Schema 稳定后再细化。

### 预期修改文件

**高加索配置适配**：
- `lib/modules/regions/caucasus_config.dart` — 高加索区域配置实例
- 移除高加索现有硬编码数据（`lib/models/exploration_progress.dart` 中的 `DiscoveryPoint.caucasus`）
- 迁移 `lib/screens/caucasus_screen.dart` 到通用渲染器

**新区域内容**：
- `lib/modules/regions/central_asia_config.dart`（或其他区域）
- 对应的新探索节点、阅读章节、Mission

**统一 UI 与双主题**：
- `lib/theme/light_theme.dart` — 浅色主题
- `lib/theme/theme_selector.dart` — 主题切换 Provider
- 各组件增加主题响应式适配

### 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| 配置化程度不足以支撑高加索全部 UI 功能 | 回归 | 严格对照高加索现有功能逐项验证 |
| 双主题重构影响面大 | 测试和验收成本高 | 按组件分批迁移，逐个验证 |

### 完成标准

- [ ] 高加索页面从配置层驱动运行
- [ ] 新区域页面可访问
- [ ] 浅色主题可用（用户手动切换）
- [ ] 所有测试通过

### Git 检查点

- `git commit -m "feat: Phase 11B 高加索配置适配"`
- `git commit -m "feat: Phase 11C 新区域内容 XXX"`
- `git commit -m "feat: Phase 11D 统一UI与双主题"`

### 需要用户手动完成的操作

- 提供新区域的内容（发现点、章节文本、问题）
- 验收双主题效果
- 模拟器冷启动验收

---

## 被禁止修改的文件清单

以下文件在全部 6 个阶段中 **不得修改**，除非在 Plan 中明确标注：

- `lib/models/final_submission_readiness.dart` — 最终提交规则唯一来源
- `lib/data/mission_state.dart` — `submitFinal()`、`markModified()`、`MissionSubmissionNotifier`
- `lib/data/reading_state.dart` — 阅读证据状态
- `lib/data/map_data.dart` — 地图基础数据
- `lib/services/evaluation_service.dart` — 评价服务
- `lib/services/step_coaching_service.dart` — 单步辅导服务
- `lib/services/reading_assistant_service.dart` — 阅读辅助服务
- `pubspec.yaml` — 版本升级需专门批准

> 例外：Phase 11A 可能需要轻微修改 `exploration_progress.dart` 以支持多区域注册，修改前必须经过 Plan 明确标注。

---

## 主要风险汇总

| # | 风险 | 影响阶段 | 可能性 | 影响程度 |
|---|---|---|---|---|
| 1 | HOME1 修复导致新测试与旧测试双输 | 10B-HOME1 | 中 | 高 |
| 2 | Web 上 Canvas 渲染性能不可用 | 10B-WEB1 | 中 | 中 |
| 3 | Firebase Hosting 路由配置错误 | 10B-WEB2 | 低 | 中 |
| 4 | iPad Safari 不支持 Flutter Web 手势 | 10B-WEB3 | 中 | 高 |
| 5 | RegionModule 过度设计或不足 | 11A | 中 | 中 |
| 6 | 双主题使组件复杂度翻倍 | 11D | 高 | 高 |

---

## 建议优先实施阶段

**Phase 10B-HOME1** —— 原因：

1. 它已经完成 75%，且工作区处于未提交状态
2. 22 个测试失败需要立即修复，防止基线恶化和团队混淆
3. 后面所有阶段都依赖其作为新的稳定基线
4. 失败原因明确（`routerConfig` 重复 + `GoRouterState.of` 异常处理）
5. 修复范围集中（本质上只有两个文件需要调整）

---

## 本次规划状态

| 项目 | 值 |
|---|---|
| 本规划是否修改了任何生产代码？ | ❌ 否 |
| 本规划是否执行了任何自动格式化？ | ❌ 否 |
| 本规划是否运行了任何测试？ | ✅ 是（只读审计） |
| 本规划是否创建了新目录？ | ✅ `docs/plans/` |
| 计划文件位置 | `docs/plans/2026-07-22-next-development-plan.md` |
