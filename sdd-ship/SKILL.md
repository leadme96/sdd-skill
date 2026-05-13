---
name: sdd-ship
description: 归档合并。最终步骤：同步 specs、归档变更、完成分支。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Ship

归档合并。SDD 工作流的最终步骤。

## Workflow

**前置**: 定位 change 目录 → 执行内置最终验证 → 确认验证通过 → Skill Dispatch（如有配置）。

**执行**（严格顺序）:
1. `openspec:sync-specs` → 同步 specs 到全局 `openspec/specs/`
2. `openspec:archive-change` → 归档到 `openspec/changes/archive/YYYY-MM-DD-<name>/`
3. `superpowers:finishing-a-development-branch` → 合并到主分支

**后置**: 确认归档成功 → 确认分支已清理 → 输出最终状态。

## 产物

```
openspec/specs/ (更新)
openspec/changes/archive/YYYY-MM-DD-<change>/ (归档)
主分支更新
```

## 参考

- errors.md: E002, E006, E010

## 下一步

- 变更已归档，可安全 `/clear` 或开始新的变更
