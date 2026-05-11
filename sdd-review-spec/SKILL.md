---
name: sdd-review-spec
description: Use to review the quality and completeness of specs before implementation. Dispatches spec-reviewer subagent.
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Review Spec

审查 spec 质量。独立 action，按需触发。大特性在实施前推荐执行。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取 `proposal.md`、`specs/`、`design.md`
3. 确认 artifact 齐备

### 核心执行（dispatch subagent）
Dispatch `spec-reviewer` subagent 进行审查。

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/reviews/spec-r<N>.md`
- 审查轮次：最多 3 轮
- 审查焦点：spec GIVEN/WHEN/THEN 场景可测试性、tasks spec 链接完整性、决策追溯完整性、路径覆盖

**保留项**：
- subagent 的自主审查逻辑
- 审查报告的格式规范

### 后置逻辑（SDD 自有）
1. 审查结果写入 `reviews/spec-r<N>.md`
2. 输出审查结论：Approved 或 Issues
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/reviews/
└── spec-r<N>.md
```


## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：E002

## 完成后引导

> 本 action 已完成，审查结果已写入 `reviews/spec-r<N>.md`。可安全 `/clear`。
>
> 审查结论：
> - Approved → `sdd-plan` 细化实施计划
> - Issues → 修正后再审
