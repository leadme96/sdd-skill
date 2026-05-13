---
name: sdd-init
description: 一站式项目初始化入口，集成 agents CLI + OpenSpec，生成 AGENTS.md + openspec/ 结构。
argument-hint: "[project-root]"
version: "2.0.0"
user-invocable: true
---

# SDD Init

初始化项目的 SDD 工作流。所有 SDD action 的起点。

## Workflow

**前置**: 检测 CLI 可用性（`agents`、`openspec`）、组件状态（`.agents/`、`openspec/`）、分层结构（Monorepo/单体）。

**执行**:
1. `agents init` → `.agents/agents.json` + `AGENTS.md`
2. `openspec init --schema sdd` → `openspec/config.yaml` + `specs/` + `changes/` + `schemas/sdd/`
3. 分层 AGENTS.md（如检测到 frontend/backend 或 handler/service/repository）

**后置**: 确认产物完整，输出下一步引导。

## 产物

```
.agents/agents.json
AGENTS.md
openspec/
├── config.yaml
├── specs/
├── changes/
└── schemas/sdd/
```

## 参考

- errors.md: E003

## 下一步

- 环境诊断 → `sdd-doctor`
- 创建变更 → `sdd-brainstorm` 或 `sdd-propose`
