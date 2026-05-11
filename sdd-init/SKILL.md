---
name: sdd-init
description: 一站式项目初始化入口，集成 agents CLI + OpenSpec，生成 AGENTS.md + CLAUDE.md + openspec/ 结构。支持 Monorepo 和分层架构的分层 AGENTS.md 生成。
argument-hint: "[project-root]"
version: "2.0.0"
user-invocable: true
---

# SDD Init

初始化项目的 SDD 工作流。这是所有 SDD action 的起点。

## 三段式结构

### 前置逻辑

#### 1. CLI 可用性检测

检查必需的 CLI 工具：

```bash
command -v agents || echo "agents CLI 未安装"
command -v openspec || echo "openspec CLI 未安装"
```

任一失败则停止，提示安装命令：
- agents CLI: `npm install -g @agents-dev/cli`
- openspec CLI: `npm install -g openspec`

#### 2. 组件状态检测

检查目标目录状态：

| 检查项 | 命令 |
|--------|------|
| .agents/ 目录 | `[ -d ".agents" ] && echo "exists"` |
| openspec/ 目录 | `[ -d "openspec" ] && echo "exists"` |
| AGENTS.md 文件 | `[ -f "AGENTS.md" ] && echo "exists"` |

#### 3. 环境检测

检测当前运行环境：

| 环境 | 检测方法 |
|------|----------|
| Claude Code | `CLAUDE_CODE` 环境变量或 `TERM_PROGRAM=claude-code` |
| Codex | `CODEX` 环境变量或 `.codex/` 目录存在 |

#### 4. 分层结构检测

检测 Monorepo 和单体分层架构：

**Monorepo 检测**：
- `frontend/package.json` 存在 → frontend
- `backend/go.mod` 或 `backend/package.json` 或 `backend/pyproject.toml` 存在 → backend

**单体分层检测**：
- `handler/` 或 `controllers/` 或 `internal/handler/` 存在 → handler
- `service/` 或 `services/` 或 `internal/service/` 存在 → service
- `repository/` 或 `dao/` 或 `internal/repository/` 存在 → repository

#### 5. 交互式确认

显示检测到的组件状态，询问用户：

```
检测到以下组件状态：
  [✓/ ] .agents/ 目录
  [✓/ ] openspec/ 目录

检测到以下分层结构：
  [✓/ ] frontend/
  [✓/ ] backend/

是否初始化？
  [y] 全部初始化
  [s] 选择性初始化
  [q] 退出
```

### 核心执行

#### 1. agents init（如用户选择）

```bash
cd "${PROJECT_ROOT:-.}" && agents init
```

**产物**：
- `.agents/agents.json`
- `AGENTS.md`（如不存在）

#### 2. openspec init（如用户选择）

```bash
cd "${PROJECT_ROOT:-.}" && openspec init --schema sdd
```

**产物**：
- `openspec/config.yaml`
- `openspec/specs/`
- `openspec/changes/`
- `openspec/schemas/sdd/`

#### 3. 生成分层 AGENTS.md（如用户选择）

根据用户选择的分层列表，为每个检测到的层生成 AGENTS.md：

- `frontend/AGENTS.md` — 组件 + API + 状态管理
- `backend/AGENTS.md` — Handler + Service + Repository
- `handler/AGENTS.md` — Handler 层规则
- `service/AGENTS.md` — Service 层规则
- `repository/AGENTS.md` — Repository 层规则

模板来源：`openspec/schemas/sdd/tech-rules/<layer>-layers.md`

如模板不存在，生成占位结构并提示用户填充。

#### 4. 工具适配层生成

**Claude Code 环境**：
```bash
echo "@AGENTS.md" > CLAUDE.md
```

**Codex 环境**：
```bash
mkdir -p .codex
echo "@../AGENTS.md" > .codex/AGENTS.md
```

### 后置逻辑

#### 1. config.yaml 修正

确保 `openspec/config.yaml` 包含：

```yaml
schema: sdd
project_context: openspec/project.md

rules:
  skill_dispatch: []
```

如字段缺失，追加写入。

#### 2. project.md 生成

创建 `openspec/project.md`（如不存在）：

```markdown
# Project Context

## 项目背景

<!-- 项目概述、业务域、核心目标 -->

## 业务知识

<!-- 领域术语、业务规则、关键概念 -->

## 团队约定

<!-- 编码规范、提交约定、分支策略 -->

## 技术栈

<!-- 由 sdd-init 根据检测结果注入 -->

## SDD Workflow

本项目使用 SDD 工作流。

**常用命令**：
- `/sdd-brainstorm` — 深度探索设计
- `/sdd-propose` — 创建变更提案
- `/sdd-ff` — 快进生成规划文档
- `/sdd-plan` — 细化实施计划
- `/sdd-apply` — TDD 实施
- `/sdd-review-code` — 代码审查
- `/sdd-ship` — 归档合并
```

#### 3. 技术栈检测注入

扫描项目文件识别技术栈：

| 检测文件 | 识别为 |
|----------|--------|
| `package.json` | Node.js |
| `tsconfig.json` | TypeScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` / `requirements.txt` | Python |
| `pom.xml` / `build.gradle` | Java |

读取对应的 `openspec/schemas/sdd/tech-rules/<stack>.md`，注入到 `openspec/project.md` 的技术栈节。

#### 4. Skill Dispatch 注入

读取 `openspec/schemas/sdd/skill-dispatch-defaults.yaml`：
1. 匹配项目检测到的技术栈
2. 将匹配规则追加到 `config.yaml` 的 `rules.skill_dispatch`

#### 5. 初始化报告输出

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SDD 初始化完成

生成的文件：
  ✓ .agents/agents.json
  ✓ AGENTS.md
  ✓ CLAUDE.md → @AGENTS.md
  ✓ openspec/config.yaml
  ✓ openspec/project.md
  ✓ openspec/schemas/sdd/

下一步：
  - 创建变更提案：/sdd-propose
  - 深度探索设计：/sdd-brainstorm
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 产物

```
<project-root>/
├── .agents/
│   └── agents.json
├── AGENTS.md
├── CLAUDE.md              # "@AGENTS.md"
├── .codex/                # 仅 Codex 环境
│   └── AGENTS.md          # "@../AGENTS.md"
├── frontend/AGENTS.md     # 可选
├── backend/AGENTS.md      # 可选
├── handler/AGENTS.md      # 可选
├── service/AGENTS.md      # 可选
├── repository/AGENTS.md   # 可选
└── openspec/
    ├── config.yaml
    ├── project.md
    ├── specs/
    ├── changes/
    └── schemas/sdd/
```

## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：E005, E008

## 完成后引导

> SDD 工作流已初始化至 `<project-root>/`。
> 已生成 AGENTS.md + CLAUDE.md + openspec/ 结构。可安全 `/clear`。
>
> 推荐下一步：
> - 创建变更提案：`/sdd-propose`
> - 深度探索设计：`/sdd-brainstorm`