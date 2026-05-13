---
name: sdd-plan
description: 细化实施计划。委托 superpowers:writing-plants。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Plan

细化实施计划。核心工作委托给 `superpowers:writing-plans`。

## Workflow

**前置**: 定位 change 目录 → 读取 `tasks.md`、`specs/`、`design.md`（如有）→ Skill Dispatch（如有配置）。

**执行**: `superpowers:writing-plans`
- Override: 输出到 `openspec/changes/<change-name>/plan.md`
- 模板: `openspec/schemas/sdd/templates/plan.md`
- 保留: 2-5 分钟粒度任务拆分、TDD 步骤结构

**后置**: Dispatch `plan-reviewer`（最多 3 轮）→ 格式校验。

## 产物

```
openspec/changes/<change-name>/
├── plan.md
└── reviews/plan-r<N>.md
```

## 参考

- errors.md: E002, E005

## 下一步

→ `sdd-apply` 开始 TDD 实施
