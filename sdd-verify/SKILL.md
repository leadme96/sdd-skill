---
name: sdd-verify
description: Use to comprehensively verify all implemented work before shipping. Invokes Superpowers verification and OpenSpec verify-change.
argument-hint: "[project-root] [change-name]"
user-invocable: true
---

# SDD Verify

全面验证。在归档前执行，确认所有工作符合预期。

## 三段式结构

### 前置逻辑（SDD 自有）
1. 定位 change 目录
2. 读取所有 artifact 和 review 结果
3. 确认所有任务已标记完成

### 核心执行（invoke 底层 skill）
Invoke 两个底层 skills：
1. `superpowers:verification-before-completion` — 执行完整测试套件
2. `openspec:verify-change` — 逐条验证 spec scenario 覆盖率

**Override 项**：
- 无（直接调用底层 skills 的默认行为）

**保留项**：
- `superpowers:verification` 的完整测试套件
- `openspec:verify-change` 的 spec 覆盖验证逻辑

**验证内容**：
- 所有测试通过
- 所有 spec 场景已实现
- review 中的 CRITICAL/HIGH 问题已修复
- 代码风格与项目一致

### 后置逻辑（SDD 自有）
1. 汇总验证报告
2. 输出验证结论：Pass 或 Fail
3. 输出下一步引导

## 产物

验证报告（输出到会话 + 可选写入 review 目录）。

## 完成后引导

> 本 action 已完成。可安全 `/clear`。
>
> 验证结论：
> - Pass → `sdd-ship` 归档合并
> - Fail → `sdd-code` 补充实现
