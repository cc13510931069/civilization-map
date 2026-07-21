# 当前交接状态

## Phase 状态

**Phase 10B 基线固化完成**，等待首个 Git 提交。

## 验证状态

| 检查项 | 结果 |
|---|---|
| `flutter test` | **154 / 154 实际通过** |
| `dart analyze` | **0 errors** |
| `flutter analyze` | 工具异常（FormatException），当前结果未知 |
| 模拟器 Phase 10A 人工验收 | **通过** |
| pending timer | 已解决 |
| `skip:` | **0** |
| completed 重复提交 | 已阻止 |
| 修订版本流程 | 必须 `markModified` → `revisionReady` |

## Git 状态

- Git 已初始化
- 首个基线提交尚未创建
- 不得推测分支或提交号，用户提交后再更新

## 测试文件

| 文件 | 测试数 |
|---|---|
| `test/smoke_test.dart` | 6 |
| `test/data_flow_test.dart` | 13 |
| `test/world_map_test.dart` | 24 |
| `test/caucasus_screen_test.dart` | 14 |
| `test/mission_submission_test.dart` | 56 |
| `test/final_submission_readiness_test.dart` | 41 |
| **总计** | **154** |

## 关键文件

| 文件 | 作用 |
|---|---|
| `lib/models/final_submission_readiness.dart` | 共享规则函数 `evaluateFinalSubmissionEligibility`、`countMissionEvidenceSources`、`FinalSubmissionBlockReason` |
| `lib/data/mission_state.dart` | 所有 Provider（`finalSubmissionReadinessProvider`、`canSubmitFinalProvider`、`missionSubmissionProvider`）、`MissionSubmissionNotifier`、`submitFinal()` completed 阶段保护 |
| `lib/components/final_submission_readiness_card.dart` | 最终提交准备卡（两个行动入口通过 `onMapAction` / `onReadingAction` 回调） |
| `lib/screens/mission_screen.dart` | Mission 主页面（`_buildFinalEvaluationCard`、`_evalRow`、`_buildSubmitArea`） |
| `docs/PROJECT_SPEC.md` | 唯一正式产品规格文档 |

## 下一阶段：Phase 10B-HOME1

### HOME1 核心目标

- 三张任务卡整卡可点击
- 地图任务进入世界地图并定位高加索
- 阅读任务进入精读营并定位第 26 章
- 文明解释任务进入 Mission
- 状态从现有 Provider 推导
- 显示未开始、进行中、已完成
- 已完成任务仍可点击
- 不创建重复本地 bool 状态
- 使用 GoRouter
- 不修改 Mission 提交规则

### 后续开发顺序

```
HOME1
→ RegionModule Schema
→ 高加索配置适配
→ 新区域内容
→ 统一 UI 和双主题
```
