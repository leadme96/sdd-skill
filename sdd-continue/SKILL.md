---
name: sdd-continue
description: Use to incrementally generate the next missing artifact in a change's dependency chain. Invokes OpenSpec continue-change.
argument-hint: "[project-root] [change-name]"
version: "1.0.0"
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

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/<next-artifact>.md`
- 模板格式：使用 `openspec/schemas/sdd/templates/<artifact>.md`
- 自动识别：根据依赖链确定下一个缺失的 artifact

**保留项**：
- `openspec:continue-change` 的依赖链判断逻辑
- 模板格式校验

依赖链（与 schema.yaml 一致）：
```
brainstorm.md ──→ proposal.md ──→ specs/ ──→ tasks.md ──→ plan.md
  (可选)            (必需)     ↗   (必需)      (必需)
                            proposal.md
                               ↓
                           design.md (可选)
```

必需 artifact：`proposal.md`、`specs/`、`tasks.md`
可选 artifact：`brainstorm.md`、`design.md`、`plan.md`

### 后置逻辑（SDD 自有）
1. 确认生成的 artifact 符合 schema 约束
2. 格式校验
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/<next-artifact>.md
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

> 本 action 已完成，产物已持久化至 `openspec/changes/<change-name>/<next-artifact>.md`。可安全 `/clear`。
>
> 推荐下一步：
> - 仍有缺失 → 继续 `sdd-continue`
> - 已补齐全 → `sdd-ff` 或 `sdd-plan`
