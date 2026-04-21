---
name: sdd-plan
description: Use when you want to refine tasks into a detailed implementation plan. Invokes superpowers:writing-plans with SDD orchestration and reviewer loop.
argument-hint: "[project-root] [change-name]"
version: "1.0.0"
user-invocable: true
---

# SDD Plan

细化实施计划。委托给 `superpowers:writing-plans`。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取 `tasks.md`、`specs/`、`design.md`（如有）
3. 确认 `tasks.md` 已存在（必需前置）
4. **Skill Dispatch 调度**（如有配置）：
   - 读取 `openspec/config.yaml` 中的 `rules.skill_dispatch`
   - 匹配当前上下文（action=plan + 项目技术栈 + 变更文件路径）
   - 匹配成功则调用指定的 skill

### 核心执行（invoke 底层 skill）
Invoke `superpowers:writing-plans` 生成 `plan.md`。

**Override 项**：
- 输出位置：`openspec/changes/<change-name>/plan.md`
- 模板格式：使用 `openspec/schemas/sdd/templates/plan.md`
- 禁止转入 `executing-plans`（SDD 控制转场节奏）
- 跳过内置 reviewer（由 SDD 后置逻辑接管）

**保留项**：
- 2-5 分钟粒度的任务拆分
- TDD 步骤结构（RED/GREEN/IMPROVE）

**tasks.md 与 plan.md 的分工**：
- `tasks.md` 回答"做什么"（spec requirement 级，checkbox + spec 链接）
- `plan.md` 回答"怎么做"（文件路径 + 测试代码 + 运行命令，2-5 分钟工程师操作级）

### 后置逻辑（SDD 自有）
1. Dispatch `plan-reviewer` 进行审查（最多 3 轮）
2. 审查焦点：任务粒度、TDD 步骤完整性、spec 对齐
3. 产物格式校验
4. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/
├── plan.md
└── reviews/
    └── plan-r<N>.md
```


## 错误处理

### 常见错误

| 错误 | 原因 | 恢复方法 |
|------|------|----------|
| change 目录不存在 | 未执行 sdd-propose | 先执行 `sdd-propose` 创建提案 |
| artifact 缺失 | 前置步骤未完成 | 执行 `sdd-ff` 补全 artifact |

### 状态检查

```bash
# 检查变更目录状态
ls openspec/changes/<change-name>/

# 检查 artifact 完整性
cat openspec/changes/<change-name>/tasks.md | grep "\[x\]"
```

## 完成后引导

> 本 action 已完成，产物已持久化至 `plan.md`。可安全 `/clear`。
>
> 推荐下一步：`sdd-apply` 开始实施
