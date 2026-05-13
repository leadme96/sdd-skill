---
name: sdd-review-code
description: 双阶段代码审查。Phase 1 spec 合规审查，Phase 2 代码质量审查。
argument-hint: "[project-root] [change-name] [batch-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Review Code

双阶段代码审查。使用 Superpowers 作为唯一执行后端。

## Workflow

**前置**: 定位 change 目录 → 读取 `specs/`、`tasks.md` → 确认待审查代码范围 → Skill Dispatch（如有配置）。

**执行**:
- Phase 1: Dispatch `spec-compliance` subagent → 检查 spec GIVEN/WHEN/THEN 场景实现、边界条件、错误处理
- Phase 1 通过后: `superpowers:requesting-code-review` → 审查可读性、设计模式、潜在问题

**后置**: 审查结果写入 `reviews/code-<batch>-r<N>.md` → 输出结论。

## 产物

```
openspec/changes/<change-name>/reviews/code-<batch>-r<N>.md
```

## 参考

- errors.md: E002, E010

## 下一步

- 有更多批次 → `sdd-apply`
- 全部完成 → `sdd-verify`
