---
name: sdd-propose
description: Use when you want to formalize a change proposal. Invokes OpenSpec continue-change to create proposal.md. Reads brainstorm if available.
argument-hint: "[project-root] [change-name]"
user-invocable: true
---

# SDD Propose

固化变更提案。核心工作委托给 `openspec:continue-change`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录：`openspec/changes/<change-name>/`
2. 读取 `brainstorm.md`（如有）
3. 检查 proposal.md 是否已存在

### 核心执行（invoke 底层 skill）
Invoke `openspec:continue-change` 生成 `proposal.md`。

使用 `openspec/schemas/sdd/templates/proposal.md` 模板。

**模板必填节**：
```markdown
## 决策追溯
<!-- 必填：引用 brainstorm.md 中的关键决策 -->
- 选择 [X] 而非 [Y]：[原因]（见 brainstorm.md §关键决策）
- 约束 [Z]：[来源]（见 brainstorm.md §约束分析）
```

### 后置逻辑（SDD 自有）
1. 决策追溯检查：验证 proposal 是否引用了 brainstorm 中的所有关键决策
2. 产物格式校验
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/proposal.md
```

## 完成后引导

> 本 action 已完成，产物已持久化至 `proposal.md`。可安全 `/clear`。
>
> 推荐下一步：
> - 逐步确认 → `sdd-continue` 生成 specs
> - 需求充分 → `sdd-ff` 快进生成所有规划文档
