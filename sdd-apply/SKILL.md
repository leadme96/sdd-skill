---
name: sdd-apply
description: 按 TDD 实施变更。使用 Superpowers 作为唯一执行后端。
argument-hint: "[project-root] [change-name] [batch-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Apply

TDD 实施变更。支持单会话顺序执行或 Team Agent 并行执行。

## Workflow

**前置**: 定位 change 目录 → 读取 `plan.md` 定位当前批次 → 更新 `tasks.md` 批次状态 → Skill Dispatch（如有配置）。

**执行**:
1. `superpowers:using-git-worktrees` → 创建 `sdd/<change-name>` 分支
2. `superpowers:test-driven-development` → RED → GREEN → IMPROVE
3. `superpowers:systematic-debugging` → 测试失败时定位根因

**Team Agent 模式** (`--team`): 按 batch 拆分任务，并行执行，最后合并。

**后置**: 更新 `tasks.md` 任务状态 → 记录 commit 摘要。

## 产物

```
目标项目代码变更
配套测试
sdd/<change-name> 分支上的 commits
```

## 参考

- errors.md: E002, E010

## 下一步

- 有更多批次 → 继续 `sdd-apply`
- 全部完成 → `sdd-review-code` 或 `sdd-verify`
