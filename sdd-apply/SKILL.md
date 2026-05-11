---
name: sdd-apply
description: Use when you want to apply the planned change using TDD. Invokes Superpowers TDD, worktrees, and debugging with SDD orchestration for batch management.
argument-hint: "[project-root] [change-name] [batch-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Apply

按 TDD 实施变更。使用 **Superpowers** 作为唯一执行后端。

## 执行后端

### Superpowers 后端

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

1. 定位 change 目录
2. 读取 `plan.md` 定位当前批次（或按 `tasks.md` 批次划分）
3. 更新 `tasks.md` 中的批次状态
4. **Skill Dispatch 调度**（如有配置）：
   - 读取 `openspec/config.yaml` 中的 `rules.skill_dispatch`
   - 匹配当前上下文（action=apply + 项目技术栈 + 变更文件路径）
   - 匹配成功则调用指定的 skill

### 核心执行

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

## Skill Dispatch

各 SDD action 在前置逻辑中会检查 `openspec/config.yaml` 的 `rules.skill_dispatch` 配置，匹配当前上下文并调用指定 skill。

匹配规则详见 `openspec/schemas/sdd/skill-dispatch-defaults.yaml`。

### Team Agent 并行执行

由 sdd 编排器负责批次拆分和并行调度。本 skill 只执行单批次 TDD 流程。

编排器判断条件：
- plan.md 包含 3+ 个批次
- 批次间无文件交叉修改
- 目标项目是 git 仓库

不满足时回退到单会话顺序执行。

## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：E002, E005, E006, E007

## 完成后引导

> 本 action 已完成（模式：<单会话 / team>，批次：<batch-name(s)>）。可安全 `/clear`。
>
> 推荐下一步：`sdd-review-code` 审查本批次
