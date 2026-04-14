# SDD — Spec-Driven Development

> **用结构消除歧义，用纪律保证质量，用归档积累智慧。**

SDD 是一套融合 **OpenSpec**（规格驱动变更管理）与 **Superpowers**（AI 执行纪律）的自定义工作流。

## 它解决什么问题

AI 辅助开发的两个核心痛点：

1. **设计共识随对话消失** — AI 在长对话中遗忘早期约束，`/clear` 后共识全部丢失
2. **AI 有能力写代码，但没有纪律维护工程质量** — 不主动先写测试，不系统定位 bug 根因

两个工具分别解决：
- **OpenSpec** 管"写什么" — 结构化 artifact（proposal → specs → design → tasks）管理每次变更
- **Superpowers** 管"怎么做" — 严格执行纪律（TDD 铁律、系统化调试、双阶段代码审查）

SDD 让两者互补。

## 核心理念

### Action Not Phases

每个操作是独立能力（action），不是必须按顺序完成的阶段（phase）。依赖关系是 **enabler**（前置 artifact 应存在），不是 **gate**（缺失则阻断）。

### 产物接力

每个 action 的输出是下一个 action 的输入，所有中间状态持久化为文件：

```
brainstorm.md → proposal.md → specs/ → design.md → tasks.md → plan.md → [代码] → [归档]
```

任意步骤之间可以安全 `/clear`，状态在文件系统中，不在对话历史里。

### 薄编排

SDD skill 只做编排，核心工作委托给底层 skill：

```
用户 ──→ sdd-* skills（唯一入口）
             │
             ├── invoke → Superpowers skills（brainstorming / TDD / debugging...）
             ├── invoke → OpenSpec skills（continue-change / ff-change / verify...）
             └── SDD 自有逻辑（前置检查 / review 循环 / 产物校验）
```

## 12 个 Actions

| Action | 委托给 | 何时使用 |
|--------|--------|----------|
| `sdd-init` | `openspec:init` | 初始化项目 SDD 工作流，检测技术栈，生成 AI 边界 |
| `sdd-doctor` | 无 | 诊断环境，检查 skill 完整性和变更状态 |
| `sdd-brainstorm` | `superpowers:brainstorming` | 想深度探索设计 |
| `sdd-propose` | `openspec:continue-change` | 想固化提案 |
| `sdd-continue` | `openspec:continue-change` | 识别并生成下一个缺失的 artifact |
| `sdd-ff` | `openspec:ff-change` | 想快进生成所有规划文档 |
| `sdd-plan` | `superpowers:writing-plans` | 想细化实施计划 |
| `sdd-code` | `superpowers:tdd` + `worktrees` + `debugging` | 想按 TDD 实施 |
| `sdd-review-spec` | subagent | 想审查 spec 质量 |
| `sdd-review-code` | subagent + `superpowers:code-review` | 想审查代码 |
| `sdd-verify` | `superpowers:verification` + `openspec:verify` | 想全面验证 |
| `sdd-ship` | `openspec:archive` + `superpowers:finish-branch` | 想归档合并 |

## 典型工作流

### 大特性标准路径

```bash
sdd-init           → openspec/ + project-context.md + project-rules.md + CLAUDE.md
/clear
sdd-brainstorm   → brainstorm.md
/clear
sdd-ff           → proposal.md + specs/ + design.md + tasks.md
/clear
sdd-review-spec  → reviews/spec-r1.md  # 大特性推荐
/clear
sdd-plan         → plan.md
/clear
sdd-code         → 批次一代码
/clear
sdd-review-code  → reviews/code-batch1-r1.md
/clear
sdd-code         → 批次二代码
/clear
sdd-review-code  → reviews/code-batch2-r1.md
/clear
sdd-verify
/clear
sdd-ship
```

### 小修复最短路径

```
sdd-init → /clear → sdd-propose → /clear → sdd-ff → /clear → sdd-plan → /clear → sdd-code → /clear → sdd-ship
```

跳过 brainstorm（需求已明确）、跳过 spec review（改动小）、跳过独立 verify（ship 内置验证）。

## 目录结构

```
openspec/
├── config.yaml                     # 项目配置（默认 schema: sdd）
├── specs/                          # 全局 spec（归档后合并至此）
├── schemas/
│   └── sdd/                        # SDD schema + 模板
│       ├── schema.yaml             # artifact 定义、依赖链、内容约束
│       └── templates/
│           ├── brainstorm.md
│           ├── proposal.md
│           ├── spec.md
│           ├── design.md
│           ├── tasks.md
│           ├── plan.md
│           └── review.md
└── changes/
    ├── <change-name>/              # 活跃变更
    │   ├── brainstorm.md
    │   ├── proposal.md
    │   ├── specs/<capability>/spec.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── plan.md
    │   └── reviews/
    │       ├── brainstorm-r1.md
    │       ├── spec-r1.md
    │       ├── plan-r1.md
    │       ├── code-batch1-r1.md
    │       └── code-final-r1.md
    └── archive/YYYY-MM-DD-<name>/  # 归档变更
```

## 三层架构

```
┌─────────────────────────────────────────────────────────────┐
│              SDD Action Skills（编排层）                       │
│  sdd-brainstorm  sdd-propose  sdd-ff  sdd-plan  sdd-code   │
│  sdd-continue  sdd-review-spec  sdd-review-code             │
│  sdd-verify  sdd-ship  sdd-doctor                           │
└───────────────┬──────────────────────┬──────────────────────┘
                │                      │
    ┌───────────▼───────────┐  ┌───────▼──────────────────────┐
    │   Superpowers（纪律层） │  │   OpenSpec（规格层）           │
    │  brainstorming         │  │  Schema / 模板系统            │
    │  writing-plans         │  │  continue-change / ff-change │
    │  test-driven-development│  │  verify-change / archive     │
    │  systematic-debugging  │  │  sync-specs                  │
    │  requesting-code-review│  │  Delta Spec 格式             │
    │  using-git-worktrees   │  │                              │
    │  verification          │  │                              │
    │  finishing-a-development-branch │                        │
    └────────────────────────┘  └──────────────────────────────┘
```

## 渐进采用策略

| 阶段 | 使用的 Action | 建立的习惯 |
|------|--------------|-----------|
| 第一阶段 | `sdd-propose` → `sdd-ff` → `sdd-plan` → `sdd-code` → `sdd-ship` | spec 驱动 + TDD |
| 第二阶段 | + `sdd-review-spec` + `sdd-review-code` | 审查纪律 |
| 第三阶段 | + `sdd-brainstorm` + `sdd-verify` | 完整工程纪律 |

## 安装

项目级安装：
```bash
for skill in sdd-doctor sdd-brainstorm sdd-propose sdd-continue sdd-ff sdd-plan sdd-code sdd-review-spec sdd-review-code sdd-verify sdd-ship; do
  ln -s "$(pwd)/sdd-skill/$skill" .claude/skills/$skill
done
```

## Next Action 引导

每个 action 完成时给出明确的下一步建议。
