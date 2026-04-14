---
name: sdd-continue
description: Use to incrementally generate the next missing artifact in a change's dependency chain. Invokes OpenSpec continue-change.
argument-hint: "[project-root] [change-name]"
user-invocable: true
---

# SDD Continue

识别并生成变更依赖链中下一个缺失的 artifact。委托给 `openspec:continue-change`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取已有 artifact 清单
3. 根据依赖链确定下一个缺失的 artifact

### 核心执行（invoke 底层 skill）
Invoke `openspec:continue-change` 生成下一个 artifact。

依赖链：
```
brainstorm.md → proposal.md → specs/ → tasks.md → plan.md
  (可选)            (必需)     ↗   (必需)      (必需)
                            proposal.md
                               ↓
                           design.md (可选)
```

必需 artifact：`proposal.md`、`specs/`、`tasks.md`
可选 artifact：`brainstorm.md`、`design.md`、`plan.md`

### 后置逻辑（SDD 自有）
1. 识别下一个缺失 artifact
2. 格式校验
3. 输出下一步引导

## 完成后引导

> 本 action 已完成。可安全 `/clear`。
>
> 推荐下一步：
> - 仍有缺失 → 继续 `sdd-continue`
> - 已补齐全 → `sdd-ff` 或 `sdd-plan`
