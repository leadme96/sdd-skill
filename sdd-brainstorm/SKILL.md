---
name: sdd-brainstorm
description: 深度探索设计方案。委托 superpowers:brainstorming 进行苏格拉底式探索。
argument-hint: "[project-root] [change-name]"
version: "2.0.0"
user-invocable: true
---

# SDD Brainstorm

深度探索设计方案。核心工作委托给 `superpowers:brainstorming`。

## Workflow

**前置**: 定位 change 目录（如不存在，先执行 `openspec new-change <change-name>`）→ 读取项目上下文 → Skill Dispatch（如有配置）。

**执行**: `superpowers:brainstorming`
- Override: 输出到 `openspec/changes/<change-name>/brainstorm.md`
- 保留: 苏格拉底式提问、方案探索、分段确认

**后置**: Dispatch `brainstorm-reviewer`（最多 3 轮）→ 格式校验。

## 产物

```
openspec/changes/<change-name>/
├── brainstorm.md
└── reviews/brainstorm-r<N>.md
```

## 参考

- errors.md: E001, E005

## 下一步

- 需求已明确 → `sdd-propose` 固化提案
- 仍需探索 → 继续 brainstorm 讨论
