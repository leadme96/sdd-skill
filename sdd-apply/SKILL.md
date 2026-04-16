---
name: sdd-apply
description: Use when you want to apply the planned change using TDD. Invokes Superpowers TDD, worktrees, and debugging with SDD orchestration for batch management.
argument-hint: "[project-root] [change-name] [batch-name]"
version: "1.0.0"
user-invocable: true
---

# SDD Apply

按 TDD 实施变更。支持两种执行后端：**Codex**（优先）和 **Superpowers**（回退）。

## 执行后端选择

### 优先：Codex 后端

当 `/codex:rescue` skill 可用时，优先委托给 Codex 执行。

**检测方式**：检查 codex plugin 是否安装及脚本可用
```bash
[ -n "${CLAUDE_PLUGIN_ROOT}" ] && [ -d "${CLAUDE_PLUGIN_ROOT}" ] && [ -f "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" ] && echo "codex available"
```

**委托方式**：调用 `codex:rescue` skill（通过 Skill tool）
```
Skill tool: codex:rescue
args: "<task-prompt> --write"
```

**Codex 执行流程**：
1. SDD 前置逻辑：定位 change 目录、读取 plan.md、确定批次
2. 构建 Codex prompt：包含 specs、design、tasks 上下文
3. 调用 `Skill` tool 执行 `codex:rescue`
4. SDD 后置逻辑：更新 tasks.md、记录 commit

### 回退：Superpowers 后端

当 Codex 不可用时，使用 Superpowers 流程：

**委托 skills**：
- `superpowers:using-git-worktrees` — 创建分支
- `superpowers:test-driven-development` — TDD 纪律
- `superpowers:systematic-debugging` — 调试失败测试

## 执行模式

`sdd-apply` 支持两种执行模式，由用户在调用时选择：

### 模式一：单会话顺序执行（默认）

适用于：小改动（1-2 个批次）、交互式探索性开发。

所有批次在当前对话中按顺序完成。

### 模式二：Team Agent 并行执行

适用于：大改动（3+ 个批次）、需要快速完成的场景。

使用 TaskCreate 将每个批次分发给独立的子 agent 并行执行：

```
sdd-apply --team <project-root> <change-name>
```

或用户说："用 team 方式执行 sdd-apply"

**Team Agent 编排策略：**

1. **批次拆分** — 读取 `plan.md`，按 batch 将任务拆分为独立子任务
2. **并行启动** — 对每个 batch 调用 TaskCreate，创建独立的 agent
3. **Agent 配置**：每个子 agent 执行完整的 TDD 纪律（RED → GREEN → IMPROVE）
   - 工作分支：`sdd/<change-name>/batch-<n>`
   - 变更目录：`openspec/changes/<change-name>/`（共享，各 batch 写入不同文件）
4. **状态监控** — 通过 TaskList + TaskOutput 跟踪各批次进度
5. **合并** — 所有批次完成后，合并到 `sdd/<change-name>` 主分支
6. **验证** — 在主分支运行一次全量测试，确保批次间无冲突

**依赖处理：**
- 无依赖的批次 → 并行执行
- 有依赖的批次 → 等待上游完成后启动

## 三段式结构

### 前置逻辑（SDD 自有）

1. **检测执行后端**
   ```bash
   # 检测 Codex plugin 可用性（包括脚本存在性检查）
   if [ -n "${CLAUDE_PLUGIN_ROOT}" ] && [ -d "${CLAUDE_PLUGIN_ROOT}" ] && [ -f "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" ]; then
     BACKEND="codex"
   else
     BACKEND="superpowers"
   fi
   ```

2. 定位 change 目录
3. 读取 `plan.md` 定位当前批次（或按 `tasks.md` 批次划分）
4. 更新 `tasks.md` 中的批次状态

### 核心执行

#### Codex 后端

**构建 prompt**：
```
## 任务背景
- Change: <change-name>
- Batch: <batch-name>
- 目标分支: sdd/<change-name>

## Spec 上下文
[读取 openspec/changes/<change-name>/specs/ 中的 spec 内容]

## Design 参考
[读取 openspec/changes/<change-name>/design.md 关键决策]

## Tasks 清单
[读取 openspec/changes/<change-name>/tasks.md 当前批次任务]

## TDD 要求
- RED: 先写失败测试
- GREEN: 最小实现通过测试
- IMPROVE: 重构优化
- 每个 commit 包含测试 + 实现
```

**执行方式**：
```
调用 Skill tool:
  skill: "codex:rescue"
  args: "<constructed-prompt> --write"
```

**Team Agent 模式 + Codex**：
- 每个 batch 通过独立的 `codex:rescue` skill 调用执行
- 使用后台 Task 并行启动多个 rescue 调用

#### Superpowers 后端

**单会话模式**：按顺序执行
1. `superpowers:using-git-worktrees` — 创建 `sdd/<change-name>` 分支
2. `superpowers:test-driven-development` — RED → GREEN → IMPROVE
3. `superpowers:systematic-debugging` — 测试失败时定位根因

**Team Agent 模式**：并行执行
1. 读取 `plan.md` 和 `tasks.md`，按 batch 拆分任务
2. 分析 batch 间的依赖关系，确定并行策略
3. 对每个独立 batch 调用 TaskCreate：
   - 子 agent 创建独立分支 `sdd/<change-name>/batch-<n>`
   - 执行完整 TDD 流程
   - 更新批次任务状态
4. 主 orchestrator 通过 TaskList/TaskOutput 监控进度
5. 所有 batch 完成后：
   - 将各分支合并到 `sdd/<change-name>`
   - 在主分支运行全量测试
6. 处理依赖：有依赖关系的 batch 按 DAG 顺序执行

**Override for using-git-worktrees**：
- 分支命名：`sdd/<change-name>`（单会话）或 `sdd/<change-name>/batch-<n>`（team 模式）
- 保留：安全验证、基线测试

**TDD 纪律全部保留**，无需 Override。

### 后置逻辑（SDD 自有）

1. 更新 `tasks.md` 中的任务状态（标记已完成的 checkbox）
2. 记录 commit 摘要
3. 输出下一步引导

## 产物

- 目标项目中的代码变更
- 配套测试
- Git commits（在 `sdd/<change-name>` 分支上）


## 错误处理

### 常见错误

| 错误 | 原因 | 恢复方法 |
|------|------|----------|
| change 目录不存在 | 未执行 sdd-propose | 先执行 `sdd-propose` 创建提案 |
| artifact 缺失 | 前置步骤未完成 | 执行 `sdd-ff` 补全 artifact |

### 状态检查

```bash
# 检查变更目录状态
ls openspec/changes/<change-name>/

# 检查 artifact 完整性
cat openspec/changes/<change-name>/tasks.md | grep "\[x\]"
```

## 完成后引导

> 本 action 已完成（后端：<Codex / Superpowers>，模式：<单会话 / team>，批次：<batch-name(s)>）。可安全 `/clear`。
>
> 推荐下一步：`sdd-review-code` 审查本批次
