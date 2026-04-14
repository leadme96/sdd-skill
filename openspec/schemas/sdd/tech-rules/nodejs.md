# Tech Rules: Node.js / JavaScript

## 边界（禁止事项）
- 不直接修改 `node_modules/`
- 不使用 `require()` 在 ESM 项目中（或反之）
- 不绕过项目的 lint 规则（ESLint / Prettier）
- 不使用已废弃的 API（如 `__dirname` 在 ESM 中）
- 不修改 `package.json` 中的依赖版本，除非 spec 明确要求

## 指引（必须遵守）
- 使用项目的模块系统（ESM 或 CommonJS），保持与现有代码一致
- 错误处理使用 `try/catch` 或 Promise `.catch()`，保持与现有模式一致
- 异步代码使用 `async/await`，不混用 callback 风格
- 环境变量通过 `process.env` 读取，不硬编码

## 测试规则
- 测试文件放在 `test/` 或 `__tests__/` 目录，与项目现有结构一致
- 使用项目已有的测试框架（Jest / Mocha / Vitest / AVA）
- 每个 spec 场景至少有一个对应的测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 API | `src/routes/` 或 `src/api/`（按项目实际结构） |
| 新增 Service | `src/services/` 或 `src/lib/` |
| 新增 Model | `src/models/` 或 `src/schemas/` |
| 新增 Middleware | `src/middleware/` |
| 新增 Config | `src/config/` |
| 测试 | `test/`、`__tests__/` 或 `*.test.js` 同目录 |

## 常见命令
- 测试：`npm test` 或 `pnpm test`
- Lint：`npm run lint`
- 构建：`npm run build`
- 启动：`npm start` 或 `npm run dev`
