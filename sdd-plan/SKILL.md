---
name: sdd-plan
description: Use when you want to refine tasks into a detailed implementation plan. Invokes superpowers:writing-plans with SDD orchestration and reviewer loop.
argument-hint: "[project-root] [change-name]"
user-invocable: true
---

# SDD Plan

细化实施计划。委托给 `superpowers:writing-plans`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取 `tasks.md`、`specs/`、`design.md`（如有）
3. 确认 `tasks.md` 已存在（必需前置）

### 核心执行（invoke 底层 skill）
Invoke `superpowers:writing-plans` 生成 `plan.md`。

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/plan.md`
- 模板格式：使用 `openspec/schemas/sdd/templates/plan.md`
- 禁止转入 `executing-plans`（SDD 控制转场节奏）
- 跳过内置 reviewer（由 SDD 后置逻辑接管）

**保留项**：
- 2-5 分钟粒度的任务拆分
- TDD 步骤结构（RED/GREEN/IMPROVE）

**tasks.md 与 plan.md 的分工**：
- `tasks.md` 回答"做什么"（spec requirement 级，checkbox + spec 链接）
- `plan.md` 回答"怎么做"（文件路径 + 测试代码 + 运行命令，2-5 分钟工程师操作级）

### 后置逻辑（SDD 自有）
1. Dispatch `plan-reviewer` 进行审查（最多 3 轮）
2. 审查焦点：任务粒度、TDD 步骤完整性、spec 对齐
3. 产物格式校验
4. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/
├── plan.md
└── reviews/
    └── plan-r<N>.md
```

## 完成后引导

> 本 action 已完成，产物已持久化至 `plan.md`。可安全 `/clear`。
>
> 推荐下一步：`sdd-code` 开始实施
