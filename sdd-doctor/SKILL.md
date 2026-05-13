---
name: sdd-doctor
description: 诊断 SDD 环境 — 检查 skill 完整性、变更状态、项目健康度。
argument-hint: "[project-root]"
version: "2.0.0"
user-invocable: true
---

# SDD Doctor

诊断 SDD 环境，检查所有依赖和状态。

## Workflow

**前置**: 扫描 `.agents/skills/` 和 `openspec/changes/` 目录。

**执行**:
1. 检查 SDD skills 完整性（12 actions）
2. 检查底层依赖（Superpowers 8 skills + OpenSpec 5 skills）
3. 检查活跃变更状态和 artifact 完整度
4. 检查 skill 版本号和 schema 兼容性

优先使用 `openspec status --json`。

**后置**: 输出诊断报告。

## 产物

诊断报告（输出到会话，不写文件）。

## 参考

- errors.md: E003

## 下一步

- 环境正常 → `sdd-propose` 创建变更提案
- 有问题 → 根据诊断报告修复后重新运行 `sdd-doctor`
