---
name: sdd
description: SDD 工作流统一入口。自动编排 sdd-* skills，支持标准路径和最短路径。输入任务描述后自动判断路径并依次调用对应 skills。
argument-hint: "[project-root] [任务描述]"
version: "2.0.0"
user-invocable: true
---

# SDD Orchestrator

SDD 工作流的统一入口。自动编排所有 sdd-* skills。

## 输入解析

| 输入模式 | 示例 | 解析结果 |
|----------|------|----------|
| `/sdd ./my-project 添加用户登录` | 有路径 + 有描述 | project-root=./my-project, 任务=添加用户登录 |
| `/sdd 添加用户登录` | 无路径 + 有描述 | project-root=当前目录, 任务=添加用户登录 |
| `/sdd ./my-project` | 有路径 + 无描述 | 交互模式，询问任务 |
| `/sdd` | 无输入 | 诊断模式，显示当前状态 |

## 路径判断

### 关键词匹配

| 关键词 | 路径 |
|--------|------|
| "修复" / "fix" / "bug" / "patch" | 最短路径 |
| "添加" / "新增" / "add" / "create" | 标准路径 |
| "重构" / "refactor" | 标准路径 + review |
| "探索" / "设计" / "brainstorm" | 从 brainstorm 开始 |

### Change 状态检测

执行以下命令检测当前状态：
```bash
openspec status --json
```

解析返回：
- `activeChanges`: 活跃变更列表
- `artifacts`: 各 artifact 状态

### 路径定义

**标准路径（大特性）**：
```
sdd-init → sdd-brainstorm → sdd-propose → sdd-ff → 
sdd-review-spec → sdd-plan → sdd-apply → sdd-review-code → 
sdd-verify → sdd-ship
```

**最短路径（小修复）**：
```
sdd-init → sdd-propose → sdd-ff → sdd-plan → sdd-apply → sdd-ship
```

### 跳过条件

| 跳过 | 条件 |
|------|------|
| `sdd-brainstorm` | 关键词匹配明确需求 或 用户确认"需求已明确" |
| `sdd-review-spec` | 变更文件数 < 3 |
| `sdd-verify` | `sdd-ship` 内置验证已足够 |

## 执行流程

### 1. 解析输入

```
输入 → 提取 project-root, 任务描述
     → 检测 project-root 是否为有效 git 仓库
     → 检测 openspec/ 是否存在
```

### 2. 检测 Change 状态

```bash
openspec status --json
```

- 有活跃 change → 继续已有 change
- 无活跃 change → 创建新 change

### 3. 判断路径

```
任务描述 → 关键词匹配 → 选择路径（标准/最短）
        → 检查跳过条件
```

### 4. 自动编排

按选定路径依次 invoke 对应 sdd-* skill：

```
WHILE 路径中有下一个 skill:
  1. 读取当前 skill 状态
  2. IF skill 前置条件满足:
       invoke skill
     ELSE:
       等待用户处理前置条件
  3. 检查产物是否生成
  4. 输出进度
END WHILE
```

### 5. Team Agent 并行执行

仅当满足以下所有条件时可用：
1. plan.md 包含 3+ 个批次
2. 批次间无文件交叉修改
3. 目标项目是 git 仓库

执行步骤：
1. 解析 plan.md 提取批次列表和依赖关系
2. 对每个独立批次创建子 agent（branch: sdd/<change>/batch-<n>）
3. 子 agent 执行：git checkout → TDD 流程 → push
4. 所有子 agent 完成后合并到 sdd/<change>
5. 全量测试验证

不可用时回退到单会话顺序执行。

## 进度输出

每完成一个 skill 输出：

```
✓ sdd-<action> 完成
  产物: openspec/changes/<change>/<artifact>.md
  
下一步: sdd-<next-action>
```

## 会话持久化

状态持久化到文件系统，不在对话历史中：
- Change 状态: `openspec/changes/<change>/.openspec.yaml`
- Git 分支: `sdd/<change>`

可安全 `/clear` 后继续。

## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：
- E003: openspec 未初始化
- E005: 底层 skill 不可用

## 完成后引导

> SDD 工作流完成。变更已归档至 `openspec/changes/archive/`。
>
> 新任务: `/sdd <新任务描述>`