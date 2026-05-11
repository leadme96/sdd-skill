# SDD Error Catalog

集中定义所有 SDD skills 的错误码。每个 skill 引用相关错误码，不重复定义。

## 错误码表

| Code | 错误 | 原因 | 恢复方法 |
|------|------|------|----------|
| E001 | change 目录不存在 | 未执行 sdd-propose | 执行 `/sdd-propose <project-root> <change-name>` |
| E002 | artifact 缺失 | 前置步骤未完成 | 执行 `/sdd-ff` 补全缺失 artifact |
| E003 | openspec 未初始化 | 项目未执行 sdd-init | 执行 `/sdd-init <project-root>` |
| E004 | 技术栈未检测 | sdd-init 未完成检测 | 重新执行 `/sdd-init <project-root>` |
| E005 | 底层 skill 不可用 | Superpowers/OpenSpec skills 未安装 | 安装依赖 skills |
| E006 | 验证失败 | 测试未通过或 spec 未覆盖 | 执行 `/sdd-apply` 修复问题 |
| E007 | Git 分支冲突 | 目标分支已存在 | 删除旧分支或使用新 change 名称 |
| E008 | 权限不足 | 无写权限 | 检查目录权限或使用管理员权限 |
| E009 | 配置文件损坏 | config.yaml 格式错误 | 修复配置文件格式 |
| E010 | Review 未通过 | 存在 CRITICAL 问题 | 修复问题后重新 review |

## 各 Skill 触发的错误码

| Skill | 可能触发 |
|-------|----------|
| sdd-init | E005, E008 |
| sdd-doctor | E003 |
| sdd-brainstorm | E001, E005 |
| sdd-propose | E001, E005 |
| sdd-continue | E001, E002, E005 |
| sdd-ff | E001, E002, E005 |
| sdd-plan | E002, E005 |
| sdd-apply | E002, E005, E006, E007 |
| sdd-review-spec | E002 |
| sdd-review-code | E002, E010 |
| sdd-verify | E002, E006 |
| sdd-ship | E002, E006, E010 |

## 错误处理模板

在 skill 中引用：

```markdown
## 错误处理

参见 `openspec/schemas/sdd/errors.md`

本 skill 可能触发：E001, E002
```

## 状态检查命令

优先使用 openspec CLI：

```bash
openspec status --change "<change-name>" --json
```

返回结构：
```json
{
  "artifacts": [
    {"id": "proposal", "status": "done"},
    {"id": "tasks", "status": "partial", "completed": 3, "total": 5}
  ]
}
```

Fallback 到文件存在性检查：

```bash
[ -f "openspec/changes/<change>/proposal.md" ] && echo "proposal: done"
```