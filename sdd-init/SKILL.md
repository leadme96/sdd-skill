---
name: sdd-init
description: Use to initialize a new project for SDD workflow. Runs openspec init, detects project tech stack, scans existing code patterns and templates, and generates project-specific context and rules with code snippets.
argument-hint: "[project-root]"
version: "1.0.0"
user-invocable: true
---

# SDD Init

初始化项目的 SDD 工作流。这是所有 SDD action 的起点。

## 职责

1. 执行 `openspec init` 建立项目规范骨架
2. 检测项目技术栈并生成对应的 AI 边界与指引
3. **扫描项目既有代码模式，提取统一模板和典型代码片段**
4. 安装 SDD schema 和模板到项目
5. 将 context 和 rules **内联写入 `openspec/config.yaml`**（不生成独立文件）
6. 生成项目级 CLAUDE.md（包含 SDD 工作流说明）
7. **注入 `skill_dispatch` 默认规则**（根据检测到的技术栈）

## 三段式结构

### 前置逻辑（SDD 自有）
1. 读取项目根目录，识别项目类型
2. 检查 `openspec/` 是否已存在
3. 读取项目 README、配置文件、依赖声明文件
4. **版本检测** — 如项目已存在 `CLAUDE.md`：
   - 提取 `<!-- principles-version: X.Y -->` 标记
   - 如无标记，视为版本 0.0
   - 如检测版本 < 当前模板版本 (1.0)，提示用户：「发现新版本原则 (1.0 > X.Y)，是否更新？」
   - 如检测版本 >= 当前模板版本，跳过更新提示
   - 如用户拒绝更新，保留现有 CLAUDE.md，继续后续步骤

### 核心执行（invoke 底层 skill）
Invoke `openspec:init` 执行项目初始化：
- 创建 `openspec/` 目录结构
- 生成 `openspec/config.yaml`（设置 `schema: sdd`）
- 创建 `openspec/changes/` 和 `openspec/specs/` 目录

**Override 项**：
- schema 设置：强制 `schema: sdd`（非默认值）
- config.yaml 格式：将 context 和 rules 内联写入，不生成独立文件

**保留项**：
- `openspec:init` 的基础目录创建逻辑
- 默认 schema/模板系统

### 后置逻辑（SDD 自有）
1. **技术栈检测** — 扫描项目，识别技术栈和框架
2. **代码模式扫描** — 提取项目统一的代码模板和典型片段（见下方规则）
3. **生成项目 context** — 内联写入 `openspec/config.yaml` 的 `context:` 字段
4. **生成项目 rules** — 内联写入 `openspec/config.yaml` 的 `rules:` 字段，注入检测到的代码模式和代码片段
5. **安装 SDD schema** — 将 `openspec/schemas/sdd/` 复制到项目
6. **注入 skill_dispatch 默认规则** — 读取 `skill-dispatch-defaults.yaml`，匹配技术栈，注入到 `config.yaml`（见下方规则）
7. **生成 CLAUDE.md** — 项目级 AI 工作流指导，使用下方模板内容
8. 输出初始化报告


## CLAUDE.md 模板内容

执行后置逻辑第 6 步时，生成以下内容的 `CLAUDE.md`：

```markdown
<!-- principles-version: 1.0 -->

# Project CLAUDE.md

## AI Behavior Principles

> **强制但有 override**：用户可显式 `ignore <原则名>` 绕过。
>
> **Override 行为指导**：
> - 当用户说「忽略所有原则」→ 停止输出所有自检问题
> - 当用户说「忽略 <原则名>」→ 停止输出该原则的自检问题
> - Override 仅在当前会话有效，不持久化

### 1. Think Before Coding
**解决**：错误假设、隐藏困惑、缺少权衡

**行为要求**：
- 遇到不确定点时，**必须提问确认**，而非假设
- 输出 `[Thinking...]` 标记，显式声明思考过程（可选）
- 如存在多种理解，呈现所有选项让用户选择
- 如发现更简单的方案，主动提出

**自检问题**：
- 我是否在不确定时做了假设？
- 我是否呈现了所有可能的解释？

### 2. Simplicity First
**解决**：过度复杂、臃肿抽象

**行为要求**：
- 只实现被请求的功能，不添加「未来可能需要」的特性
- 单次使用的代码不创建抽象层
- 不添加未被请求的「灵活性」或「可配置性」
- 不为不可能发生的场景写错误处理

**自检问题**：
- 200 行能否变成 50 行？
- 资深工程师会说这是过度复杂吗？

### 3. Surgical Changes
**解决**：无关编辑、触碰不应碰的代码

**行为要求**：
- 只修改与任务直接相关的代码
- 不「顺便」改进相邻代码、注释或格式
- 不重构没坏的代码
- 匹配现有代码风格，即使你不会这样写
- 说明变更范围和关键修改点

**自检问题**：
- 每一行变更是否都能追溯到用户的请求？

### 4. Goal-Driven Execution
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
- 必须在输出中声明决策理由，格式：「[原则A] 优先于 [原则B]，因为 [原因]」
- 示例：「目标驱动优先于简洁优先，因为可验证性更重要」

## SDD Workflow

使用 SDD 工作流进行开发。详见 SDD 文档。

**常用 action**：
- `sdd-brainstorm` — 深度探索设计
- `sdd-propose` — 创建变更提案
- `sdd-ff` — 快进生成规划文档
- `sdd-plan` — 细化实施计划
- `sdd-apply` — TDD 实施
- `sdd-review-code` — 代码审查
- `sdd-ship` — 归档合并

## Action Checkpoints

| Action | 相关原则 | 检查点 |
|--------|----------|--------|
| sdd-apply | 目标驱动 | 输出验收标准 |
| sdd-apply | 精准修改 | 说明变更范围和关键修改点 |
| sdd-brainstorm | 编码前思考 | 显式提问确认 |
| sdd-plan | 编码前思考 | 输出假设列表和权衡分析 |
| sdd-review-code | 简洁优先 | 检查是否过度复杂 |
| sdd-review-code | 精准修改 | 检查变更边界 |
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
├── openspec/
│   ├── config.yaml                    # schema: sdd + context + rules（含代码模式 + skill_dispatch）
│   ├── specs/                         # 全局 spec
│   ├── changes/                       # 活跃变更
│   └── schemas/sdd/                   # SDD schema + 模板（安装副本）
└── CLAUDE.md                          # 项目级 AI 工作流指导

# 全局默认规则（安装在 sdd-skill 中）
sdd-skill/openspec/schemas/sdd/
└── skill-dispatch-defaults.yaml       # 全局默认调度规则
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

> 本 action 已完成，SDD 工作流已初始化至 `<project-root>/openspec/`。
> context 和 rules（含 N 种代码模式 + skill_dispatch 规则）已写入 `config.yaml`。可安全 `/clear`。
>
> 推荐下一步：
> - 需求明确 → `sdd-propose` 创建第一个变更提案
> - 需探索设计 → `sdd-brainstorm` 深度探索
> - 需求充分 → `sdd-ff` 快进生成所有规划文档
