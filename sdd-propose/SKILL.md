---
name: sdd-propose
description: Use when you want to formalize a change proposal. Invokes OpenSpec continue-change to create proposal.md. Reads brainstorm if available.
argument-hint: "[project-root] [change-name]"
version: "1.0.0"
user-invocable: true
---

# SDD Propose

固化变更提案。核心工作委托给 `openspec:continue-change`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录：`openspec/changes/<change-name>/`
2. 读取 `brainstorm.md`（如有）
3. 检查 proposal.md 是否已存在
4. **Skill Dispatch 调度**（如有配置）：
   - 读取 `openspec/config.yaml` 中的 `rules.skill_dispatch`
   - 匹配当前上下文（action=propose + 项目技术栈 + 变更文件路径）
   - 匹配成功则调用指定的 skill

### 核心执行（invoke 底层 skill）
Invoke `openspec:continue-change` 生成 `proposal.md`。

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/proposal.md`
- 模板格式：使用 `openspec/schemas/sdd/templates/proposal.md`
- 必填节约束：`决策追溯` 节必须引用 brainstorm.md 中的关键决策

**保留项**：
- `openspec:continue-change` 的 artifact 生成逻辑
- 模板格式校验

### 后置逻辑（SDD 自有）
1. 决策追溯检查：验证 proposal 是否引用了 brainstorm 中的所有关键决策
2. 产物格式校验
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/proposal.md
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

> 本 action 已完成，产物已持久化至 `proposal.md`。可安全 `/clear`。
>
> 推荐下一步：
> - 逐步确认 → `sdd-continue` 生成 specs
> - 需求充分 → `sdd-ff` 快进生成所有规划文档
