---
name: sdd-propose
description: 固化变更提案。委托 openspec:continue-change 生成 proposal.md。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Propose

固化变更提案。核心工作委托给 `openspec:continue-change`。

## Workflow

**前置**: 定位 change 目录 → 读取 `brainstorm.md`（如有）→ Skill Dispatch（如有配置）。

**执行**: `openspec:continue-change`
- Override: 输出到 `openspec/changes/<change-name>/proposal.md`
- 模板: `openspec/schemas/sdd/templates/proposal.md`

**后置**: 决策追溯检查 → 格式校验。

## 产物

```
openspec/changes/<change-name>/proposal.md
```

## 参考

- errors.md: E001, E005

## 下一步

- 逐步确认 → `sdd-continue` 生成 specs
- 需求充分 → `sdd-ff` 快进生成所有规划文档
