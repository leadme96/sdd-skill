---
name: sdd-init
description: Use to initialize a new project for SDD workflow. Runs openspec init, detects project tech stack, scans existing code patterns and templates, and generates project-specific context and rules with code snippets.
argument-hint: "[project-root]"
user-invocable: true
---

# SDD Init

初始化项目的 SDD 工作流。这是所有 SDD action 的起点。

## 职责

1. 执行 `openspec init` 建立项目规范骨架
2. 检测项目技术栈并生成对应的 AI 边界与指引
3. **扫描项目既有代码模式，提取统一模板和典型代码片段**
4. 安装 SDD schema 和模板到项目
5. 生成项目级 CLAUDE.md（包含 SDD 工作流说明）

## 三段式结构

### 前置逻辑（SDD 自有）
1. 读取项目根目录，识别项目类型
2. 检查 `openspec/` 是否已存在
3. 读取项目 README、配置文件、依赖声明文件

### 核心执行（invoke 底层 skill）
Invoke `openspec:init` 执行项目初始化：
- 创建 `openspec/` 目录结构
- 生成 `openspec/config.yaml`（设置 `schema: sdd`）
- 创建 `openspec/changes/` 和 `openspec/specs/` 目录

### 后置逻辑（SDD 自有）
1. **技术栈检测** — 扫描项目，识别技术栈和框架
2. **代码模式扫描** — 提取项目统一的代码模板和典型片段（见下方规则）
3. **生成项目 context** — 写入 `openspec/project-context.md`
4. **生成项目 rules** — 写入 `openspec/project-rules.md`，注入检测到的代码模式和代码片段
5. **安装 SDD schema** — 将 `openspec/schemas/sdd/` 复制到项目
6. **生成 CLAUDE.md** — 项目级 AI 工作流指导
7. 输出初始化报告

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

### 输出到 `project-rules.md`

提取的代码模式写入 `project-rules.md` 的"代码模式参考"节，格式如下：

```markdown
## 代码模式参考

### Handler 模式
来源: `src/routes/user.js`
<!-- 展示项目的 Handler 统一写法 -->
```<language>
<code snippet>
```

### Service 模式
来源: `src/services/userService.js`
<!-- 展示 Service 层统一结构 -->
```<language>
<code snippet>
```
```

这样后续 `sdd-code` 执行时，AI 可以参考这些片段保持项目既有风格。

## 输出

```
<project-root>/
├── openspec/
│   ├── config.yaml                    # schema: sdd
│   ├── project-context.md             # 项目技术栈、架构、模块边界
│   ├── project-rules.md               # AI 边界、指引 + 代码模式参考（含代码片段）
│   ├── specs/                         # 全局 spec
│   ├── changes/                       # 活跃变更
│   └── schemas/sdd/                   # SDD schema + 模板（安装副本）
└── CLAUDE.md                          # 项目级 AI 工作流指导
```

## 完成后引导

> 本 action 已完成，SDD 工作流已初始化至 `<project-root>/openspec/`。
> 已提取 N 种代码模式到 `project-rules.md`。可安全 `/clear`。
>
> 推荐下一步：
> - 需求明确 → `sdd-propose` 创建第一个变更提案
> - 需探索设计 → `sdd-brainstorm` 深度探索
> - 需求充分 → `sdd-ff` 快进生成所有规划文档
