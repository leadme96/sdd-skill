# SDD Session Context

## 会话级状态

SDD 工作流的所有状态持久化到文件系统，不在对话历史中。

### 状态存储位置

| 状态 | 位置 |
|------|------|
| Change 元数据 | `openspec/changes/<change>/.openspec.yaml` |
| Artifact 文件 | `openspec/changes/<change>/*.md` |
| Git 分支 | `sdd/<change>` |
| 归档 | `openspec/changes/archive/YYYY-MM-DD-<change>/` |

### /clear 安全性

`/clear` 命令只清除对话历史，不影响文件系统中的任何状态。

以下操作可在 `/clear` 后继续：
- 继续已有 change：`/sdd <project-root>`
- 查看状态：`/sdd-doctor <project-root>`
- 执行下一步：根据 `openspec status` 输出调用对应 skill

### 不适合 /clear 的场景

以下 action 是交互式的，中途 `/clear` 会丢失上下文：
- `sdd-brainstorm` — 苏格拉底式提问需要对话历史
- `sdd-plan` — 任务分解讨论需要对话历史
- `sdd-apply` — TDD 流程中的调试需要错误信息

建议：这些 action 完成后再 `/clear`。

### 会话恢复检查清单

`/clear` 后恢复会话时：

```bash
# 1. 检查当前 change 状态
openspec status --json

# 2. 检查 git 分支
git branch | grep sdd/

# 3. 检查 artifact 完整性
ls openspec/changes/<change>/
```

根据检查结果确定下一步 action。