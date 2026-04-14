---
name: sdd-review-code
description: Use to review code after implementation. Two-phase: Phase 1 spec-compliance review (SDD subagent), Phase 2 code quality review (invoke superpowers:requesting-code-review).
argument-hint: "[project-root] [change-name] [batch-name]"
user-invocable: true
---

# SDD Review Code

双阶段代码审查。每个实施批次后执行。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取 `specs/`、`tasks.md`
3. 确认待审查的代码变更范围

### Phase 1：Spec 合规审查（SDD 自有逻辑）
Dispatch `spec-compliance` subagent 审查：
- 代码是否实现了 spec 中的 GIVEN/WHEN/THEN 场景
- 边界条件是否处理
- 错误处理是否完整
- 变更是否超出 spec 范围

**Phase 1 必须通过后才进入 Phase 2。**
理由：如果代码没有实现 spec 要求的功能，讨论代码质量毫无意义。先确认"做对了"，再讨论"做好了"。

### Phase 2：代码质量审查（invoke 底层 skill）
Invoke `superpowers:requesting-code-review` 审查：
- 可读性
- 设计模式
- 潜在问题
- 性能

### 后置逻辑（SDD 自有）
1. 审查结果写入 `reviews/code-<batch>-r<N>.md`
2. 输出审查结论
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/reviews/
└── code-<batch>-r<N>.md
```

## 完成后引导

> 本 action 已完成，审查结果已写入。可安全 `/clear`。
>
> 推荐下一步：
> - 有更多批次 → `sdd-code`
> - 全部完成 → `sdd-verify`
