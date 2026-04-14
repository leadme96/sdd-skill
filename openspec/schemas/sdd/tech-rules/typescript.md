# Tech Rules: TypeScript

## 边界（禁止事项）
- 不绕过 TypeScript 严格模式（`strict: true`）
- 不使用 `any` 类型（除非 spec 明确允许且注释说明原因）
- 不使用 `@ts-ignore` / `@ts-expect-error`（除非 spec 明确允许且注释说明原因）
- 不绕过项目的 lint 规则（ESLint / Prettier）
- 不修改 `package.json` 中的依赖版本，除非 spec 明确要求

## 指引（必须遵守）
- 所有公共 API 必须有显式类型注解
- 使用接口/类型而非 `any` 或隐式推断
- 错误处理使用 `try/catch` 并正确缩小错误类型
- 保持与项目既有模块系统一致（ESM / CommonJS）

## 测试规则
- 测试文件放在 `test/` 或 `__tests__/` 目录，`*.test.ts` 命名
- 使用项目已有的测试框架（Jest / Vitest / Mocha）
- 运行测试：`npm test` 或 `pnpm test`
- 每个 spec 场景至少有一个测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 API | `src/routes/` 或 `src/controllers/` |
| 新增 Service | `src/services/` |
| 新增 Type/Interface | `src/types/` 或同目录 `types.ts` |
| 新增 Model | `src/models/` |
| 测试 | `test/`、`__tests__/` 或 `*.test.ts` 同目录 |

## 常见命令
- 测试：`npm test`
- Lint：`npm run lint`
- 类型检查：`npx tsc --noEmit`
- 构建：`npm run build`
