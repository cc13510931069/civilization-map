# 开发状态

## 已完成阶段

- **Phase 1-9**：基础架构、世界地图、高加索探索、字体系统、证据库、UI 布局
- **Phase 10A**：完整 Mission 学习闭环
- **Phase 10B**：基线固化与测试修复

### Phase 10A 详细完成内容

- 五步草稿保持（`stepAnswersProvider` 持久化、`TextEditingController` 链、`FocusNode` 聚焦）
- 单步辅导与多次修订（`StepCoachingNotifier`、三级提示、跳过/取消跳过）
- 初步反馈与最终评价（`submitInitial` → `initialFeedback` → `submitFinal` → `completed`）
- 正式快照和多版本提交（`missionResultSnapshotProvider`、`submissionVersion`）
- MyMap 数据闭环（展示正式快照的五步答案、证据、画像、评价）
- 最终提交准备卡（`FinalSubmissionReadinessCard`、条件清单 + 行动入口）
- 最终提交规则单一来源（`evaluateFinalSubmissionEligibility`、`countMissionEvidenceSources`）
- 地图或阅读**任意一条证据**即可满足条件
- 两个证据行动入口（"去地图探索"和"去精读营"）
- GoRouter 导航修复（移除 `Navigator.pushNamed`，改用 `context.go`）
- 评价卡横向 overflow 修复（标题 `Expanded` + `TextOverflow.ellipsis`）

### Phase 10B 详细完成内容

- 测试语法结构修复（多余括号、重复测试声明）
- C10–C12 文本查找方式修复（`find.text` → `find.textContaining`）
- H 系列 pending timer 修复（`testWidgets` → `test` + `await submitFinal()`）
- `submitFinal()` 增加 `completed` 阶段保护，拒绝重复提交
- 多版本修订流程修复（必须 `markModified()` → `revisionReady` → 提交）
- HF4F 缺失测试恢复（I01–I04：回调行为）
- 多版本测试恢复（H49–H51：修订流程验证）
- 项目文档合并与更新（双主题暂缓，HOME1 列为下一阶段）
- 全局调试输出清理
- 154/154 完整测试基线恢复

## 当前稳定基线

| 测试集 | 通过数 |
|---|---|
| `smoke_test.dart` | 6 / 6 |
| `data_flow_test.dart` | 13 / 13 |
| `world_map_test.dart` | 24 / 24 |
| `caucasus_screen_test.dart` | 14 / 14 |
| `mission_submission_test.dart` | 56 / 56 |
| `final_submission_readiness_test.dart` | 41 / 41 |
| **完整测试** | **154 / 154** |
| **dart analyze** | **0 errors** |
| **flutter analyze** | 工具异常，当前结果未知 |
| **模拟器 Phase 10A 验收** | **通过** |

无 pending timer、无 skip、无语法错误。
`completed` 状态重复提交已阻止，修订版本必须经过 `markModified` → `revisionReady`。

## Phase 10A 关键规则

### 最终提交条件

1. 五步答案均至少 6 字符
2. 地图证据或阅读证据**任意一条**即可
3. 当前不处于提交中

### 统一规则函数

三者共用 `evaluateFinalSubmissionEligibility()`：

- `canSubmitFinalProvider`
- `finalSubmissionReadinessProvider`
- `submitFinal()`

### 证据分类

`countMissionEvidenceSources()` — 唯一的地图/阅读证据分类纯函数。

### FinalSubmissionBlockReason

| BlockReason | 中文文案 |
|---|---|
| `incompleteSteps` | 请完善全部五步思考后再提交。 |
| `missingEvidence` | 请先收集至少一条地图或阅读证据。 |
| `submissionInProgress` | Veggie 正在评价，请稍候。 |

## 下一阶段

**Phase 10B-HOME1**：首页"今日文明任务"导航闭环。
