---
name: sdd-ff
description: 快进生成所有缺失的规划文档。委托 openspec:ff-change。停在 tasks.md。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD FF (Fast Forward)

快进生成所有缺失的规划文档。核心工作委托给 `openspec:ff-change`。

## Workflow

**前置**: 定位 change 目录 → 识别所有缺失的 artifact → 确认 `proposal.md` 已存在。

**执行**: `openspec:ff-change`
- Override: 不生成 `plan.md`（由 `sdd-plan` 单独生成）
- ff 自然停在 `tasks.md`

**后置**: 批量校验所有生成的 artifact → 格式校验。

## 产物

```
openspec/changes/<change-name>/
├── proposal.md
├── specs/<capability>/spec.md
├── design.md? (如需要)
└── tasks.md
```

## 参考

- errors.md: E001, E002, E005

## 下一步

- 大特性 → `sdd-review-spec` 审查 spec 质量
- 小修复 → `sdd-plan` 细化实施计划
