---
name: sdd-continue
description: 生成依赖链中下一个缺失的 artifact。委托 openspec:continue-change。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Continue

识别并生成变更依赖链中下一个缺失的 artifact。

## Workflow

**前置**: 定位 change 目录 → 读取已有 artifact 清单 → 确定下一个缺失的 artifact。

**执行**: `openspec:continue-change`
- Override: 输出到 `openspec/changes/<change-name>/<next-artifact>.md`
- 模板: `openspec/schemas/sdd/templates/<artifact>.md`

依赖链: `brainstorm.md? → proposal.md → specs/ → tasks.md → plan.md?`

**后置**: Schema 约束校验 → 格式校验。

## 产物

```
openspec/changes/<change-name>/<next-artifact>.md
```

## 参考

- errors.md: E001, E002, E005

## 下一步

- 仍有缺失 → 继续 `sdd-continue`
- 已补齐全 → `sdd-plan` 细化实施计划
