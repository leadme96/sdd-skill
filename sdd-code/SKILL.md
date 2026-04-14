---
name: sdd-code
description: Use when you want to implement a change using TDD. Invokes Superpowers TDD, worktrees, and debugging with SDD orchestration for batch management.
argument-hint: "[project-root] [change-name] [batch-name]"
user-invocable: true
---

# SDD Code

按 TDD 实施变更。委托给多个 Superpowers skills。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取 `plan.md` 定位当前批次（或按 `tasks.md` 批次划分）
3. 更新 `tasks.md` 中的批次状态

### 核心执行（invoke 底层 skill）
Invoke 三个 Superpowers skills：
1. `superpowers:using-git-worktrees` — 创建 `sdd/<change-name>` 分支
2. `superpowers:test-driven-development` — RED → GREEN → IMPROVE
3. `superpowers:systematic-debugging` — 测试失败时定位根因

**Override for using-git-worktrees**：
- 分支命名：`sdd/<change-name>`
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

## 完成后引导

> 本 action 已完成（批次：<batch-name>）。可安全 `/clear`。
>
> 推荐下一步：`sdd-review-code` 审查本批次
