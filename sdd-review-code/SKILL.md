---
name: sdd-review-code
description: Use to review code after implementation. Two-phase: Phase 1 spec-compliance review (SDD subagent), Phase 2 code quality review (invoke superpowers:requesting-code-review).
argument-hint: "[project-root] [change-name] [batch-name]"
version: "1.1.0"
user-invocable: true
---

# SDD Review Code

双阶段代码审查。使用 **Superpowers** 作为唯一执行后端。

## 三段式结构

### 前置逻辑（SDD 自有）

1. 定位 change 目录
2. 读取 `specs/`、`tasks.md`
3. 确认待审查的代码变更范围
4. **Skill Dispatch 调度**（如有配置）：
   - 读取 `openspec/config.yaml` 中的 `rules.skill_dispatch`
   - 匹配当前上下文（action=review + 项目技术栈 + 变更文件路径）
   - 匹配成功则调用指定的 skill

### 核心执行

**Phase 1：Spec 合规审查**（SDD subagent）
Dispatch `spec-compliance` subagent 审查：
- 代码是否实现了 spec 中的 GIVEN/WHEN/THEN 场景
- 边界条件是否处理
- 错误处理是否完整
- 变更是否超出 spec 范围

**Phase 1 通过条件**：无 CRITICAL 问题，或 CRITICAL 问题已修复。只有 Phase 1 通过后才进入 Phase 2。

理由：如果代码没有实现 spec 要求的功能，讨论代码质量毫无意义。先确认"做对了"，再讨论"做好了"。

**Phase 2：代码质量审查**（invoke 底层 skill）
Invoke `superpowers:requesting-code-review` 审查：
- 可读性
- 设计模式
- 潜在问题
- 性能

**Override 项**：
- Phase 1 输出位置：`openspec/changes/<change-name>/reviews/code-<batch>-r<N>.md`
- Phase 2 审查范围：仅审查 Phase 1 已通过的代码

**保留项**：
- `superpowers:requesting-code-review` 的完整审查能力
- 两阶段审查的严格顺序（Phase 1 → Phase 2）

### 后置逻辑（SDD 自有）

1. 审查结果写入 `reviews/code-<batch>-r<N>.md`
2. 输出审查结论
3. 输出下一步引导

## 产物

```
openspec/changes/<change-name>/reviews/
└── code-<batch>-r<N>.md
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

> 本 action 已完成，审查结果已持久化至 `reviews/code-<batch>-r<N>.md`。可安全 `/clear`。
>
> 推荐下一步：
> - 有更多批次 → `sdd-apply`
> - 全部完成 → `sdd-verify`
