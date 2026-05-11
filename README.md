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
用户 ──→ sdd skills（唯一入口）
              │
              ├── invoke → Superpowers skills（brainstorming / TDD / debugging...）
              ├── invoke → OpenSpec skills（continue-change / ff-change / verify...）
              └── SDD 自有逻辑（前置检查 / review 循环 / 产物校验）
```

## 双轨架构

### 统一入口（自动编排）

```bash
/sdd ./my-project 添加用户登录    # 自动判断路径并执行
/sdd ./my-project               # 显示当前状态
```

### 独立入口（手动调用）

```bash
/sdd-init ./my-project          # 初始化项目
/sdd-doctor ./my-project        # 诊断环境
/sdd-propose ./my-project ...   # 创建变更提案
/sdd-brainstorm ./my-project    # 深度探索设计
/sdd-ff ./my-project ...        # 快进生成规划文档
/sdd-plan ./my-project ...      # 细化实施计划
/sdd-apply ./my-project ...     # TDD 实施
/sdd-review-spec ./my-project   # Spec 审查
/sdd-review-code ./my-project   # 代码审查
/sdd-verify ./my-project        # 综合验证
/sdd-ship ./my-project          # 归档合并
```

## 目录结构

```
sdd-skill/
├── .agents/skills/sdd/           # 编排器
│   ├── SKILL.md
│   └── prompts/session-context.md
├── openspec/schemas/sdd/        # Schema + 模板 + 配置
│   ├── schema.yaml
│   ├── templates/
│   ├── tech-rules/
│   ├── errors.md                # 集中错误码
│   ├── prompts/                 # Reviewer prompts
│   └── skill-dispatch-defaults.yaml
├── sdd-init/SKILL.md
├── sdd-doctor/SKILL.md
├── sdd-brainstorm/SKILL.md
├── sdd-propose/SKILL.md
├── sdd-continue/SKILL.md
├── sdd-ff/SKILL.md
├── sdd-plan/SKILL.md
├── sdd-apply/SKILL.md
├── sdd-review-spec/SKILL.md
├── sdd-review-code/SKILL.md
├── sdd-verify/SKILL.md
├── sdd-ship/SKILL.md
├── README.md
├── CLAUDE.md
└── install.sh
```

## 13 个 Actions

| Action | 委托给 | 何时使用 |
|--------|--------|----------|
| `sdd` | 编排器 | 统一入口，自动编排 |
| `sdd-init` | `openspec init` + tech detection | 项目初始化 |
| `sdd-doctor` | 无 | 诊断环境 |
| `sdd-brainstorm` | `superpowers:brainstorming` | 想深度探索设计 |
| `sdd-propose` | `openspec:continue-change` | 想固化提案 |
| `sdd-continue` | `openspec:continue-change` | 生成下一个缺失 artifact |
| `sdd-ff` | `openspec:ff-change` | 快进生成所有规划文档 |
| `sdd-plan` | `superpowers:writing-plans` | 细化实施计划 |
| `sdd-apply` | `superpowers:tdd` | TDD 实施 |
| `sdd-review-spec` | subagent | Spec 审查 |
| `sdd-review-code` | `superpowers:requesting-code-review` | 代码审查 |
| `sdd-verify` | `superpowers:verification` + `openspec:verify` | 综合验证 |
| `sdd-ship` | `openspec:archive` + `superpowers:finish-branch` | 归档合并 |

## 典型工作流

### 大特性标准路径

```bash
sdd-init           → .agents/ + AGENTS.md + openspec/
/clear
sdd-brainstorm   → brainstorm.md
/clear
sdd-ff           → proposal.md + specs/ + design.md + tasks.md
/clear
sdd-review-spec  → reviews/spec-r1.md
/clear
sdd-plan         → plan.md
/clear
sdd-apply         → 批次一代码
/clear
sdd-review-code  → reviews/code-batch1-r1.md
/clear
sdd-apply         → 批次二代码
/clear
sdd-review-code  → reviews/code-batch2-r1.md
/clear
sdd-verify
/clear
sdd-ship
```

### 小修复最短路径

```
sdd-init → /clear → sdd-propose → /clear → sdd-ff → /clear → sdd-plan → /clear → sdd-apply → /clear → sdd-ship
```

跳过 brainstorm（需求已明确）、跳过 spec review（改动小）、跳过独立 verify（ship 内置验证）。

## 安装

项目级安装：
```bash
bash install.sh
```

或手动安装：
```bash
# 安装编排器
mkdir -p .agents/skills
ln -s "$(pwd)/sdd-skill/.agents/skills/sdd" .agents/skills/sdd

# 安装 12 个 action skills
mkdir -p .claude/skills
for skill in sdd-init sdd-doctor sdd-brainstorm sdd-propose sdd-continue sdd-ff sdd-plan sdd-apply sdd-review-spec sdd-review-code sdd-verify sdd-ship; do
  ln -s "$(pwd)/sdd-skill/$skill" .claude/skills/$skill
done
```

卸载：
```bash
rm -rf .agents/skills/sdd .claude/skills/sdd-*
```

## Next Action 引导

每个 action 完成时给出明确的下一步建议。