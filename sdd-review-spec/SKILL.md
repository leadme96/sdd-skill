---
name: sdd-review-spec
description: 审查 spec 质量。Dispatch spec-reviewer subagent。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Review Spec

审查 spec 质量。独立 action，大特性在实施前推荐执行。

## Workflow

**前置**: 定位 change 目录 → 读取 `proposal.md`、`specs/`、`design.md` → 确认 artifact 齐备。

**执行**: Dispatch `spec-reviewer` subagent
- 审查焦点: spec GIVEN/WHEN/THEN 场景可测试性、tasks spec 链接完整性、决策追溯完整性、路径覆盖
- 最多 3 轮

**后置**: 审查结果写入 `reviews/spec-r<N>.md` → 输出结论（Approved/Issues）。

## 产物

```
openspec/changes/<change-name>/reviews/spec-r<N>.md
```

## 参考

- errors.md: E002

## 下一步

- Approved → `sdd-plan` 细化实施计划
- Issues → 修正后再审
