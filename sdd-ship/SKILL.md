---
name: sdd-ship
description: Use to finalize a change — run final verification, sync specs to global store, archive the change, and finish the branch. Invokes OpenSpec and Superpowers skills.
argument-hint: "[project-root] [change-name]"
version: "1.0.0"
user-invocable: true
---

# SDD Ship

归档合并。SDD 工作流的最终步骤。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 执行最终验证（内置验证，不依赖 sdd-verify 已执行）
3. 确认验证通过

### 核心执行（invoke 底层 skill，顺序执行三步）
按顺序 invoke 三个底层 skills：

**Override 项**：
- 执行顺序：三步必须严格顺序执行，不能跳过或颠倒
  1. `openspec:sync-specs` → 将变更中的 specs 同步到全局 `openspec/specs/`
  2. `openspec:archive-change` → 将变更目录归档到 `openspec/changes/archive/YYYY-MM-DD-<name>/`
  3. `superpowers:finishing-a-development-branch` → 完成开发分支（合并到主分支）

**保留项**：
- `openspec:sync-specs` 的全局 spec 同步逻辑
- `openspec:archive-change` 的归档逻辑
- `superpowers:finishing-a-development-branch` 的分支合并逻辑

### 后置逻辑（SDD 自有）
1. 确认归档成功
2. 确认分支已清理
3. 输出最终状态

## 产物

- 全局 specs 更新
- 变更归档
- 主分支更新


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

> 本 action 已完成，变更已归档至 `openspec/changes/archive/`。可安全 `/clear`。
