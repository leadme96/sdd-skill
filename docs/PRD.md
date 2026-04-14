# SDD Skill PRD

## 目标

交付一套可安装的 SDD（Spec-Driven Development）skill set，融合 OpenSpec 的规格驱动变更管理与 Superpowers 的 AI 执行纪律。

## 核心问题

AI 辅助开发的两个痛点：
1. **设计共识随对话消失** — AI 遗忘早期约束，`/clear` 后共识丢失
2. **AI 有能力写代码，但没有纪律维护工程质量** — 不主动先写测试

## 解决方案

- **OpenSpec** 管"写什么" — 结构化 artifact 管理变更
- **Superpowers** 管"怎么做" — 严格执行 TDD、调试、审查纪律
- **SDD** 是薄编排层，只做编排，核心工作委托给底层 skill

## MVP 范围

12 个独立 skills：
- `sdd-init` — 项目初始化 + 技术栈检测 + AI 边界生成
- `sdd-doctor` — 环境诊断
- `sdd-brainstorm` — 设计探索 + brainstorm-reviewer
- `sdd-propose` — 提案固化
- `sdd-continue` — 增量 artifact 生成
- `sdd-ff` — 快进生成所有规划文档
- `sdd-plan` — 实施计划 + plan-reviewer
- `sdd-code` — TDD 实施
- `sdd-review-spec` — spec 审查
- `sdd-review-code` — 双阶段代码审查
- `sdd-verify` — 全面验证
- `sdd-ship` — 归档合并

Schema + 7 个模板：
- schema.yaml — artifact 定义、依赖链、内容约束
- templates: brainstorm, proposal, spec, design, tasks, plan, review
- config.yaml — context + rules（含代码模式参考）
- tech-rules: nodejs, go, python, java, rust, typescript

## 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 架构模式 | 薄编排（invoke 委托） | 消除逻辑复制和版本漂移 |
| 用户入口 | 只有 sdd-* | 消除三套入口的选择困惑 |
| Schema instruction | 只管内容约束 | 执行者无法执行流程编排指令 |
| Override 策略 | 具体路径 + 具体禁止 | 提高可靠性 |
| design 可选化 | tasks/plan 不硬依赖 design | 简单变更不需要技术设计 |
| ff 不生成 plan | apply 依赖 tasks 而非 plan | plan 单独由 writing-plans 纪律保证 |
| tasks vs plan 共存 | 分开（what vs how） | 合并会导致粒度混乱 |
| 代码审查分两阶段 | spec 合规 → 代码质量 | 先确认"做对了"再讨论"做好了" |

## 非目标

- 不跨仓库扫描/改代码
- 不做 Persona 生成
- 不修改 OpenSpec 或 Superpowers 的原有文件
- 不引入外部平台级通用扫描 DSL
