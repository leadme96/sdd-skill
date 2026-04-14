---
name: sdd-review-spec
description: Use to review the quality and completeness of specs before implementation. Dispatches spec-reviewer subagent.
argument-hint: "[project-root] [change-name]"
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

**审查焦点**：
- spec GIVEN/WHEN/THEN 场景是否可测试
- tasks [spec:domain#scenario] 链接是否完整
- proposal/design 的"决策追溯"节是否填写
- 需求场景是否覆盖正常路径和边界路径
- 是否存在歧义或遗漏

### 后置逻辑（SDD 自有）
1. 审查结果写入 `reviews/spec-r<N>.md`
2. 输出审查结论：Approved 或 Issues
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/reviews/
└── spec-r<N>.md
```

## 完成后引导

> 本 action 已完成，审查结果已写入 `reviews/spec-r<N>.md`。可安全 `/clear`。
>
> 审查结论：
> - Approved → `sdd-plan` 细化实施计划
> - Issues → 修正后再审
