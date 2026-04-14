---
name: sdd-doctor
description: Use when diagnosing the SDD environment — check skill completeness, change status, and project health before starting any SDD action.
argument-hint: "[project-root]"
user-invocable: true
---

# SDD Doctor

诊断 SDD 环境，检查：
1. 所有 sdd-* skills 是否已安装
2. 底层依赖（OpenSpec、Superpowers）是否可用
3. 当前活跃变更状态
4. 项目健康度

## 三段式结构

### 前置逻辑（SDD 自有）
1. 扫描 `.claude/skills/` 目录，检查 sdd-* skills 完整性
2. 扫描 `openspec/changes/` 目录，识别活跃变更

### 核心执行（无委托，纯 SDD 自有逻辑）
不 invoke 任何底层 skill，全部逻辑为 SDD 自有诊断：

1. **检查 SDD skills 完整性**
   - 扫描 `.claude/skills/` 下是否有全部 12 个 sdd-* skills（含 sdd-init）
   - 列出缺失项

2. **检查底层依赖**
   - 确认 OpenSpec skills 可用（continue-change, ff-change, verify-change, archive, sync-specs）
   - 确认 Superpowers skills 可用（brainstorming, writing-plans, test-driven-development, systematic-debugging, requesting-code-review, verification, finishing-a-development-branch, using-git-worktrees）

3. **检查活跃变更**
   - 扫描 `openspec/changes/` 下的活跃变更目录
   - 每个变更检查 artifact 完整度（哪些已有，哪些缺失）

### 后置逻辑（SDD 自有）
1. 汇总诊断结果
2. 输出技能缺失清单、活跃变更状态、建议下一步操作

## 产物

诊断报告（输出到会话，不写文件），不包含任何代码变更。

## 完成后引导

> 本 action 已完成，诊断报告已输出。可安全 `/clear`。
>
> 推荐下一步：
> - 有缺失 skill → 安装后重新运行 `sdd-doctor`
> - 环境正常 → `sdd-propose` 创建变更提案
