---
name: sdd-ff
description: Use when you want to fast-forward and generate all missing planning artifacts at once. Invokes OpenSpec ff-change. Stops at tasks.md (plan is generated separately).
argument-hint: "[project-root] [change-name]"
user-invocable: true
---

# SDD FF (Fast Forward)

快进生成所有缺失的规划文档。委托给 `openspec:ff-change`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 识别所有缺失的 artifact
3. 确认 proposal.md 已存在（必需前置）

### 核心执行（invoke 底层 skill）
Invoke `openspec:ff-change` 批量生成所有缺失 artifact。

**Override 项**：
- 不生成 `plan.md`——plan 由 `sdd-plan` 单独生成，确保 plan 质量由 Superpowers 的 writing-plans 纪律保障
- ff 自然停在 `tasks.md`

**保留项**：
- `openspec:ff-change` 的批量生成逻辑
- 所有模板格式校验

### 后置逻辑（SDD 自有）
1. 批量校验所有生成的 artifact
2. 格式校验
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/
├── proposal.md
├── specs/<capability>/spec.md
├── design.md（如需要）
└── tasks.md
```

## 完成后引导

> 本 action 已完成，所有规划文档已生成至 `openspec/changes/<change-name>/`。可安全 `/clear`。
>
> 推荐下一步：
> - 大特性 → `sdd-review-spec` 审查 spec 质量
> - 小修复 → `sdd-plan` 细化实施计划
