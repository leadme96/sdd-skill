---
name: sdd-brainstorm
description: Use when you want to deeply explore design alternatives before committing to a spec. Invokes superpowers:brainstorming with SDD orchestration.
argument-hint: "[project-root] [change-name]"
version: "1.0.0"
user-invocable: true
---

# SDD Brainstorm

深度探索设计方案。SDD 编排层，核心工作委托给 `superpowers:brainstorming`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录：`openspec/changes/<change-name>/`
2. 读取项目上下文（README、关键源码、已有 artifact）
3. 检查前置条件：change 目录是否已存在

### 核心执行（invoke 底层 skill）
Invoke `superpowers:brainstorming` 进行苏格拉底式探索。

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/brainstorm.md`
- 模板格式：使用 `openspec/schemas/sdd/templates/brainstorm.md`
- 禁止转入 `writing-plans`（SDD 控制转场节奏）
- 跳过内置 reviewer（由 SDD 后置逻辑接管）

**保留项**：
- 苏格拉底式提问
- 方案探索
- 分段确认

### 后置逻辑（SDD 自有）
1. Dispatch `brainstorm-reviewer` 进行审查（最多 3 轮）
2. 审查焦点：方案完整性、决策清晰度、YAGNI
3. 产物格式校验
4. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/
├── brainstorm.md
└── reviews/
    └── brainstorm-r<N>.md
```


## 错误处理

### 常见错误

| 错误 | 原因 | 恢复方法 |
|------|------|----------|
| change 目录不存在 | 未执行 sdd-propose | 先执行 `sdd-propose` 创建提案 |
| artifact 缺失 | 前置步骤未完成 | 执行 `sdd-ff` 补全 artifact |

### 状态检查

```bash
# 检查变更目录状态
ls openspec/changes/<change-name>/

# 检查 artifact 完整性
cat openspec/changes/<change-name>/tasks.md | grep "\[x\]"
```

## 完成后引导

> 本 action 已完成，产物已持久化至 `openspec/changes/<change-name>/brainstorm.md`。
> 如需释放上下文，可安全 `/clear`。
>
> 推荐下一步：
> - 需求已明确 → `sdd-propose` 固化提案
> - 仍需探索 → 继续 brainstorm 讨论
