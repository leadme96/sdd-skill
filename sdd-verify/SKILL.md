---
name: sdd-verify
description: 全面验证所有已实现工作。调用 Superpowers verification + OpenSpec verify-change。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Verify

全面验证。在归档前执行，确认所有工作符合预期。

## Workflow

**前置**: 定位 change 目录 → 读取所有 artifact 和 review 结果 → 确认所有任务已标记完成 → Skill Dispatch（如有配置）。

**执行**:
1. `superpowers:verification-before-completion` → 执行完整测试套件
2. `openspec:verify-change` → 逐条验证 spec scenario 覆盖率

**后置**: 汇总验证报告 → 输出结论（Pass/Fail）。

## 产物

验证报告（输出到会话 + 可选写入 review 目录）。

## 参考

- errors.md: E002, E006

## 下一步

- Pass → `sdd-ship` 归档合并
- Fail → `sdd-apply` 补充实现
