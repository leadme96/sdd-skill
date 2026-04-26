---
name: sdd-init
description: 一站式项目初始化入口，集成 agents CLI + OpenSpec，生成 AGENTS.md + CLAUDE.md + openspec/ 结构。支持 Monorepo 和分层架构的分层 AGENTS.md 生成。
argument-hint: "[project-root]"
version: "1.1.0"
user-invocable: true
---

# SDD Init

初始化项目的 SDD 工作流。这是所有 SDD action 的起点。

## 职责

一站式项目初始化入口，集成：
1. **agents CLI** — 生成 AGENTS.md（AI 行为规范）
2. **OpenSpec CLI** — 建立 openspec/（Spec 管理）
3. **技术栈检测** — 注入项目特定规则
4. **工具适配层** — 生成 Claude Code/Codex 配置文件

## 三段式结构

### 前置逻辑（SDD 自有）

#### 1. CLI 可用性检测

```bash
# 检测 agents CLI
if ! command -v agents &> /dev/null; then
  echo "错误：agents CLI 未安装"
  echo "安装命令：npm install -g @agents-dev/cli"
  exit 1
fi

# 检测 openspec CLI
if ! command -v openspec &> /dev/null; then
  echo "错误：openspec CLI 未安装"
  echo "安装命令：npm install -g openspec"
  exit 1
fi
```

#### 2. 组件状态检测

```bash
# 检测 .agents/
AGENTS_EXISTS=$([ -d ".agents" ] && echo "✓" || echo " ")

# 检测 openspec/
OPENSPEC_EXISTS=$([ -d "openspec" ] && echo "✓" || echo " ")
```

#### 3. 环境检测

```bash
# 检测 Claude Code
IS_CLAUDE=$([ -n "$CLAUDE_CODE" ] || [ "$TERM_PROGRAM" = "claude-code" ] && echo "true" || echo "false")

# 检测 Codex
IS_CODEX=$([ -n "$CODEX" ] || [ -d ".codex" ] && echo "true" || echo "false")
```

#### 4. 显示组件状态

```
检测到以下组件状态：

  [${OPENSPEC_EXISTS}] openspec/ 目录
  [${AGENTS_EXISTS}] .agents/ 目录

是否初始化缺失组件？

  [y] 全部初始化
  [s] 选择性初始化
  [q] 退出
```

#### 5. 版本检测（如 CLAUDE.md 已存在）

- 提取 `<!-- principles-version: X.Y -->` 标记
- 如无标记，视为版本 0.0
- 如检测版本 < 当前模板版本 (1.0)，提示用户：「发现新版本原则 (1.0 > X.Y)，是否更新？」
- 如用户拒绝更新，保留现有 CLAUDE.md，继续后续步骤

#### 6. 分层结构检测

检测 Monorepo 前后端分离和单体应用分层架构：

```bash
# Monorepo 检测
MONOREPO_FRONTEND=$([ -d "frontend" ] && [ -f "frontend/package.json" ] && echo "frontend" || echo "")
MONOREPO_BACKEND=""
if [ -d "backend" ]; then
  if [ -f "backend/go.mod" ] || [ -f "backend/package.json" ] || [ -f "backend/pyproject.toml" ]; then
    MONOREPO_BACKEND="backend"
  fi
fi

# 分层架构检测
LAYER_HANDLER=$([ -d "handler" ] || [ -d "controllers" ] || [ -d "internal/handler" ] && echo "handler" || echo "")
LAYER_SERVICE=$([ -d "service" ] || [ -d "services" ] || [ -d "internal/service" ] && echo "service" || echo "")
LAYER_REPOSITORY=""
if [ -d "repository" ] || [ -d "repositories" ] || [ -d "dao" ] || [ -d "internal/repository" ]; then
  LAYER_REPOSITORY="repository"
fi

# 汇总检测结果
DETECTED_LAYERS=()
[ -n "$MONOREPO_FRONTEND" ] && DETECTED_LAYERS+=("$MONOREPO_FRONTEND")
[ -n "$MONOREPO_BACKEND" ] && DETECTED_LAYERS+=("$MONOREPO_BACKEND")
[ -n "$LAYER_HANDLER" ] && DETECTED_LAYERS+=("$LAYER_HANDLER")
[ -n "$LAYER_SERVICE" ] && DETECTED_LAYERS+=("$LAYER_SERVICE")
[ -n "$LAYER_REPOSITORY" ] && DETECTED_LAYERS+=("$LAYER_REPOSITORY")
```

#### 7. 分层 AGENTS.md 交互式确认

如检测到分层结构，显示交互式提示：

```
检测到以下分层结构：

  [✓] frontend/ 目录（React 项目）
  [✓] backend/ 目录（Go 项目）
  [✓] handler/ 目录
  [✓] service/ 目录
  [✓] repository/ 目录

是否生成分层 AGENTS.md？建议生成以规范 AI 在各层的代码风格。

  [y] 全部生成
  [s] 选择性生成（交互选择）
  [q] 跳过

请选择: _
```

用户选择 `[s]` 时显示逐项选择：

```
选择要生成的分层 AGENTS.md：

  [x] frontend/AGENTS.md（组件 + API + 状态管理）
  [x] backend/AGENTS.md（Handler + Service + Repository）
  [ ] handler/AGENTS.md（Handler 层规则）
  [ ] service/AGENTS.md（Service 层规则）
  [ ] repository/AGENTS.md（Repository 层规则）

空格选择/取消，回车确认，q 退出
```

如无检测到任何分层结构，跳过此步骤，继续后续初始化流程。

### 交互式确认（如用户选择 [s]）

```
选择要初始化的组件：

  [x] .agents/ 目录（agents CLI 管理，生成 AGENTS.md）
  [x] openspec/ 目录（Spec 管理）

空格选择/取消，回车确认，q 退出
```

### 核心执行

#### 1. agents init（如用户选择）

```bash
cd "${PROJECT_ROOT:-.}" && agents init
```

**产物**：
- `.agents/agents.json`
- `AGENTS.md`（如不存在）

**注意**：agents init 为交互式命令，需用户输入配置。

#### 2. openspec init（如用户选择）

```bash
cd "${PROJECT_ROOT:-.}" && openspec init --schema sdd
```

**产物**：
- `openspec/config.yaml`
- `openspec/specs/`
- `openspec/changes/`
- `openspec/schemas/sdd/`

**Override**：强制 `schema: sdd`（非默认值）

#### 3. 生成分层 AGENTS.md（如用户选择）

根据用户选择的分层列表，生成对应的 AGENTS.md 文件：

```bash
generate_layered_agents() {
  local layers=("$@")
  local template_dir="openspec/schemas/sdd/tech-rules"

  for layer in "${layers[@]}"; do
    local output_file="${layer}/AGENTS.md"
    local template="${template_dir}/${layer}-layers.md"

    if [ ! -d "${layer}" ]; then
      echo "警告：目录 ${layer} 不存在，跳过"
      continue
    fi

    # 加载模板
    if [ -f "$template" ]; then
      cat "$template" > "$output_file"
    else
      # Fallback：使用基础模板结构
      echo "# ${layer} Layer Rules" > "$output_file"
      echo "" >> "$output_file"
      echo "## 职责说明" >> "$output_file"
      echo "<!-- 待填充 -->" >> "$output_file"
      echo "" >> "$output_file"
      echo "## 依赖关系" >> "$output_file"
      echo "<!-- 待填充 -->" >> "$output_file"
    fi

    # 扫描代码模式并追加
    _scan_and_append_patterns "$layer" "$output_file"

    echo "✓ 已生成 ${output_file}"
  done
}

# 扫描并追加代码模式
_scan_and_append_patterns() {
  local layer="$1"
  local output_file="$2"
  local patterns=""

  # 尝试扫描代码模式
  patterns=$(_scan_layer_patterns "$layer")

  if [ -z "$patterns" ]; then
    # Fallback：无代码可扫描时保留占位符
    echo "" >> "$output_file"
    echo "## 代码模式示例" >> "$output_file"
    echo "<!-- 项目暂无代码，待后续填充 -->" >> "$output_file"
  else
    echo "" >> "$output_file"
    echo "## 代码模式示例" >> "$output_file"
    echo "$patterns" >> "$output_file"
  fi
}
```

**产物**：
- `frontend/AGENTS.md`（Monorepo，可选）
- `backend/AGENTS.md`（Monorepo，可选）
- `handler/AGENTS.md`（单体分层，可选）
- `service/AGENTS.md`（单体分层，可选）
- `repository/AGENTS.md`（单体分层，可选）

### 工具适配层生成

#### Claude Code 环境

```bash
if [ "$IS_CLAUDE" = "true" ]; then
  echo "@AGENTS.md" > CLAUDE.md
  echo "已生成 CLAUDE.md → @AGENTS.md"
fi
```

#### Codex 环境

```bash
if [ "$IS_CODEX" = "true" ]; then
  mkdir -p .codex
  echo "@../AGENTS.md" > .codex/AGENTS.md
  echo "已生成 .codex/AGENTS.md → @../AGENTS.md"
fi
```

### AGENTS.md 内嵌模板

如 agents init 未生成 AGENTS.md，或用户选择覆盖，使用以下内嵌模板：

```markdown
<!-- principles-version: 1.0 -->

# AI Behavior Principles

> **强制但有 override**：用户可显式 `ignore <原则名>` 绕过。

## 1. Think Before Coding
**解决**：错误假设、隐藏困惑、缺少权衡

**行为要求**：
- 遇到不确定点时，**必须提问确认**，而非假设
- 输出 `[Thinking...]` 标记，显式声明思考过程
- 如存在多种理解，呈现所有选项让用户选择
- 如发现更简单的方案，主动提出

**自检问题**：
- 我是否在不确定时做了假设？
- 我是否呈现了所有可能的解释？

## 2. Simplicity First
**解决**：过度复杂、臃肿抽象

**行为要求**：
- 只实现被请求的功能，不添加「未来可能需要」的特性
- 单次使用的代码不创建抽象层
- 不添加未被请求的「灵活性」或「可配置性」
- 不为不可能发生的场景写错误处理

**自检问题**：
- 200 行能否变成 50 行？
- 资深工程师会说这是过度复杂吗？

## 3. Surgical Changes
**解决**：无关编辑、触碰不应碰的代码

**行为要求**：
- 只修改与任务直接相关的代码
- 不「顺便」改进相邻代码、注释或格式
- 不重构没坏的代码
- 匹配现有代码风格，即使你不会这样写
- 说明变更范围和关键修改点

**自检问题**：
- 每一行变更是否都能追溯到用户的请求？

## 4. Goal-Driven Execution
**解决**：通过测试优先、可验证的成功标准

**行为要求**：
- 将命令式任务转换为可验证目标
- 多步骤任务输出简要计划 + 验证检查点
- 每个变更输出验收标准，完成后确认

**任务转换示例**：
| 命令 | 转换为 |
|------|--------|
| "添加验证" | "为无效输入写测试，然后让测试通过" |
| "修复 bug" | "写一个能复现它的测试，然后让测试通过" |

## 原则优先级

| 优先级 | 原则 | 覆盖关系 |
|--------|------|----------|
| 1 | Goal-Driven Execution | > Simplicity First |
| 2 | Surgical Changes | > Simplicity First |

**冲突决策指导**：
- 当原则产生冲突时，按优先级决策
- 必须在输出中声明决策理由
- 示例：「目标驱动优先于简洁优先，因为可验证性更重要」
```

### 后置逻辑（SDD 自有）

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

## Action Checkpoints

| Action | 相关原则 | 检查点 |
|--------|----------|--------|
| sdd-apply | Goal-Driven | 输出验收标准 |
| sdd-apply | Surgical | 说明变更范围 |
| sdd-brainstorm | Think Before | 显式提问确认 |
| sdd-plan | Think Before | 输出假设列表 |
| sdd-review-code | Simplicity | 检查过度复杂 |
| sdd-review-code | Surgical | 检查变更边界 |
```

#### 3. 技术栈检测注入

复用现有技术栈检测逻辑（见下方 `## 技术栈检测规则`）：
- 扫描项目文件识别技术栈
- 读取对应的 `openspec/schemas/sdd/tech-rules/<stack>.md`
- 注入到 `openspec/project.md` 的 `## 技术栈` 节

#### 4. 初始化报告输出

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

## 技术栈检测规则

通过以下文件识别技术栈：

| 检测文件 | 识别为 |
|----------|--------|
| `package.json` | Node.js/JavaScript |
| `tsconfig.json` | TypeScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` / `requirements.txt` / `setup.py` | Python |
| `pom.xml` / `build.gradle` | Java |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `*.csproj` / `*.sln` | C#/.NET |
| `CMakeLists.txt` / `Makefile` | C/C++ |

## 代码模式扫描规则

扫描项目时，针对检测到的技术栈，提取以下统一代码模式：

### 扫描目标

| 模式类型 | 说明 | 扫描方法 |
|----------|------|----------|
| **入口模式** | 项目启动入口文件 | 读取入口文件（main/app/index/cmd） |
| **路由/Handler 模式** | API 或请求处理器的定义方式 | 扫描 routes/controllers/handler 目录，取 1-2 个典型文件 |
| **Service 模式** | 业务逻辑层的组织方式 | 扫描 services 目录，取 1 个典型文件 |
| **Model/Entity 模式** | 数据模型的定义方式 | 扫描 models/entities 目录，取 1-2 个典型定义 |
| **错误处理模式** | 项目中统一的错误处理方式 | 扫描 error 相关文件或异常处理代码 |
| **测试模式** | 测试用例的编写方式 | 扫描测试目录，取 1 个典型测试文件 |
| **配置模式** | 项目配置加载方式 | 扫描 config 目录或配置文件 |

### 分层目录扫描（用于生成分层 AGENTS.md）

针对 Monorepo 和单体分层架构，额外扫描以下目录：

| 分层 | 扫描目录 | 典型文件 |
|------|----------|----------|
| **frontend/components** | `frontend/src/components/` | 取 1 个典型组件 |
| **frontend/api** | `frontend/src/api/` 或 `frontend/src/services/` | 取 1 个请求封装 |
| **frontend/state** | `frontend/src/store/` | 取 1 个 store 定义 |
| **backend/handler** | `backend/handler/` 或 `backend/controllers/` | 取 1 个典型文件 |
| **backend/service** | `backend/service/` | 取 1 个典型文件 |
| **backend/repository** | `backend/repository/` 或 `backend/dao/` | 取 1 个典型文件 |
| **handler** | `handler/` 或 `controllers/` 或 `internal/handler/` | 取 1 个典型文件 |
| **service** | `service/` 或 `services/` 或 `internal/service/` | 取 1 个典型文件 |
| **repository** | `repository/` 或 `dao/` 或 `internal/repository/` | 取 1 个典型文件 |

### 分层扫描函数

```bash
_scan_layer_patterns() {
  local layer="$1"
  local patterns=""

  case "$layer" in
    frontend)
      patterns=$(_scan_frontend_patterns)
      ;;
    backend)
      patterns=$(_scan_backend_patterns)
      ;;
    handler)
      patterns=$(_scan_handler_patterns)
      ;;
    service)
      patterns=$(_scan_service_patterns)
      ;;
    repository)
      patterns=$(_scan_repository_patterns)
      ;;
  esac

  echo "$patterns"
}

_scan_frontend_patterns() {
  local result=""
  # 扫描组件
  if [ -d "frontend/src/components" ]; then
    local comp_file=$(find frontend/src/components -name "*.tsx" -o -name "*.vue" | head -1)
    if [ -n "$comp_file" ]; then
      result+="### 组件示例\n来源: ${comp_file}\n\`\`\`tsx\n$(head -40 "$comp_file")\n\`\`\`\n\n"
    fi
  fi
  echo "$result"
}

_scan_backend_patterns() {
  local result=""
  # 扫描 Handler
  if [ -d "backend/handler" ] || [ -d "backend/controllers" ]; then
    local handler_dir=$(ls -d backend/handler backend/controllers 2>/dev/null | head -1)
    local handler_file=$(find "$handler_dir" -name "*.go" | head -1)
    if [ -n "$handler_file" ]; then
      result+="### Handler 示例\n来源: ${handler_file}\n\`\`\`go\n$(head -40 "$handler_file")\n\`\`\`\n\n"
    fi
  fi
  echo "$result"
}
```

### 提取规则

1. **只取典型**：每种模式只取 1-2 个最具代表性的文件，不全部复制
2. **保留注释**：提取的代码片段保留原有注释和文档字符串
3. **标注来源**：每个代码片段标注原始文件路径
4. **控制长度**：单个代码片段不超过 80 行，超长文件截取前 80 行 + `...`
5. **去重**：相似的模式只保留一个最完整的

### 输出到 `config.yaml`

提取的代码模式写入 `openspec/config.yaml` 的 `rules.code_patterns:` 字段，格式如下：

```yaml
rules:
  code_patterns:
    handler:
      source: "src/routes/user.js"
      snippet: |
        // 展示项目的 Handler 统一写法
        ...
    service:
      source: "src/services/userService.js"
      snippet: |
        // 展示 Service 层统一结构
        ...
```

这样后续 `sdd-apply` 执行时，AI 可以参考这些片段保持项目既有风格。

## Skill Dispatch 注入规则

### 默认规则来源

全局默认规则存储于 `openspec/schemas/sdd/skill-dispatch-defaults.yaml`，包含多种技术栈的默认调度配置。

### 注入流程

1. **读取默认规则** — 从 `skill-dispatch-defaults.yaml` 读取 `defaults:` 数组
2. **匹配技术栈** — 对每条规则，检查其 `trigger.tech_stack` 是否全部存在于项目检测到的技术栈中
3. **phases 校验** — 跳过包含无效 `phases` 值的规则，记录警告
4. **合并已有配置** — 如 `config.yaml` 已有 `skill_dispatch` 配置，保留用户配置，仅追加不重复的默认规则
5. **注入规则** — 将匹配的规则追加到 `config.yaml` 的 `rules.skill_dispatch` 字段

### 匹配算法

```python
def match_rule(rule, detected_tech_stack):
    # 规则的 tech_stack 需全部存在于检测到的技术栈中
    return all(ts in detected_tech_stack for ts in rule.trigger.tech_stack)
```

### 边界处理

| 场景 | 处理方式 |
|------|----------|
| 无匹配规则 | `rules.skill_dispatch` 不创建或为空数组 |
| 技术栈为空 | 跳过注入 |
| 用户已有配置 | 保留用户配置，追加不重复的默认规则 |
| phases 含无效值 | 跳过该规则，记录警告 |
| config.yaml 解析错误 | 报错并提示用户修复，不覆盖现有配置 |

### 去重逻辑

按 `trigger.tech_stack` + `skill` 组合判断重复：
- 如用户已有 `tech_stack: [python, fastapi], skill: "xxx"` 的规则，则不追加相同组合的默认规则

### 有效 phases 枚举

- `brainstorm` — 设计探索阶段
- `propose` — 提案固化阶段
- `plan` — 实施计划阶段
- `apply` — TDD 实现阶段
- `review` — 代码审查阶段
- `verify` — 综合验证阶段
- `ship` — 归档合并阶段

## 产物

```
<project-root>/
├── .agents/                           # agents CLI 管理
│   └── agents.json
├── AGENTS.md                          # Karpathy 4 原则（通用规范）
├── CLAUDE.md                          # "@AGENTS.md" 单行引用（Claude Code）
├── .codex/                            # 仅 Codex 环境
│   └── AGENTS.md                      # "@../AGENTS.md"
├── frontend/                          # Monorepo 前端（可选）
│   └── AGENTS.md                      # 前端分层规则
├── backend/                           # Monorepo 后端（可选）
│   └── AGENTS.md                      # 后端分层规则
├── handler/                           # 单体分层（可选）
│   └── AGENTS.md                      # Handler 层规则
├── service/                           # 单体分层（可选）
│   └── AGENTS.md                      # Service 层规则
├── repository/                        # 单体分层（可选）
│   └── AGENTS.md                      # Repository 层规则
└── openspec/
    ├── config.yaml                    # 精简：引用 project.md
    ├── project.md                     # 详细：项目信息 + SDD 工作流
    ├── specs/                         # 全局 spec
    ├── changes/                       # 活跃变更
    └── schemas/sdd/                   # SDD schema + 模板（安装副本）
```


## 错误处理

### 常见错误

| 错误 | 原因 | 恢复方法 |
|------|------|----------|
| openspec/ 已存在 | 项目已初始化 | 检查 `openspec/config.yaml` 是否完整 |
| 无写权限 | 权限不足 | 检查目录权限或使用管理员权限 |
| CLAUDE.md 已存在 | 项目已有配置 | 版本检测逻辑会提示是否更新 |

### 状态检查

```bash
# 检查初始化结果
ls openspec/

# 检查 CLAUDE.md 版本
grep "principles-version" CLAUDE.md
```

## 完成后引导

> 本 action 已完成，SDD 工作流已初始化至 `<project-root>/`。
> 已生成 AGENTS.md + CLAUDE.md + openspec/ 结构。可安全 `/clear`。
>
> 推荐下一步：
> - 创建变更提案：`/sdd-propose`
> - 深度探索设计：`/sdd-brainstorm`
