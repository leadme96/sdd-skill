---
name: sdd-doctor
description: Use when diagnosing the SDD environment — check skill completeness, change status, and project health before starting any SDD action.
argument-hint: "[project-root]"
version: "2.0.0"
user-invocable: true
---

# SDD Doctor

诊断 SDD 环境，检查所有依赖和状态。

## 三段式结构

### 前置逻辑

1. 扫描目标项目的 `.agents/skills/` 或 `.claude/skills/` 目录
2. 扫描 `openspec/changes/` 目录
3. 检测 `openspec/config.yaml` 是否存在

### 核心执行

#### 1. 检查 SDD skills 完整性

扫描 skills 目录下是否有以下 skills：

**编排器**：
- `sdd` (orchestrator)

**Action skills**：
- `sdd-init`, `sdd-doctor`, `sdd-brainstorm`, `sdd-propose`, `sdd-continue`
- `sdd-ff`, `sdd-plan`, `sdd-apply`, `sdd-review-spec`
- `sdd-review-code`, `sdd-verify`, `sdd-ship`

列出缺失项。

#### 2. 检查底层依赖

确认以下 skills 可用：

**Superpowers**:
- brainstorming, writing-plans, test-driven-development
- systematic-debugging, requesting-code-review, verification
- finishing-a-development-branch, using-git-worktrees

**OpenSpec**:
- continue-change, ff-change, verify-change, archive, sync-specs

#### 3. 检查活跃变更

扫描 `openspec/changes/` 下的活跃变更目录：
- 列出每个 change 的名称
- 检查 artifact 完整度（哪些已有，哪些缺失）
- 显示当前阶段

优先使用 openspec CLI：
```bash
openspec status --json
```

Fallback 到文件存在性检查。

#### 4. 检查 Skill 版本号

扫描每个 SKILL.md 的 `version` 字段：
- 验证版本号格式是否符合 semver（X.Y.Z）
- 列出版本号缺失或格式错误的 skill

#### 5. 检查 Schema 兼容性

读取 `openspec/config.yaml` 中的 schema 版本：
- 对比各 skill 依赖的 schema 版本
- 报告不兼容情况

### 后置逻辑

输出诊断报告：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SDD 诊断报告

Skills 完整性：
  ✓ sdd (orchestrator) v2.0.0
  ✓ sdd-init v2.0.0
  ...
  ✗ sdd-xyz (缺失)

底层依赖：
  ✓ Superpowers: 8/8 skills 可用
  ✓ OpenSpec: 5/5 skills 可用

活跃变更：
  change-1: proposal ✓, tasks ✓, plan ○ (缺失)
  change-2: 完整，可执行 sdd-apply

建议：
  - 安装缺失的 skills
  - 执行 sdd-ff 补全 change-1 的缺失 artifact
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 产物

诊断报告（输出到会话，不写文件）。

## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：E003

## 完成后引导

> 诊断完成。可安全 `/clear`。
>
> 如有问题：
> - 缺失 skill → 安装后重新运行 `sdd-doctor`
> - artifact 缺失 → 执行 `sdd-ff` 补全
> - 环境正常 → `sdd-propose` 创建变更提案