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

## 处理步骤

1. **检查 SDD skills 完整性**
   - 扫描 `.claude/skills/` 下是否有全部 12 个 sdd-* skills（含 sdd-init）
   - 列出缺失项

2. **检查底层依赖**
   - 确认 OpenSpec skills 可用（continue-change, ff-change, verify-change, archive, sync-specs）
   - 确认 Superpowers skills 可用（brainstorming, writing-plans, test-driven-development, systematic-debugging, requesting-code-review, verification, finishing-a-development-branch, using-git-worktrees）

3. **检查活跃变更**
   - 扫描 `openspec/changes/` 下的活跃变更目录
   - 每个变更检查 artifact 完整度（哪些已有，哪些缺失）

4. **输出诊断报告**
   - Skill 缺失清单
   - 当前活跃变更状态
   - 建议下一步操作

## 输出

诊断报告，不包含任何代码变更。
