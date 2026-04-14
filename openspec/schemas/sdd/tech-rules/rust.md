# Tech Rules: Rust

## 边界（禁止事项）
- 不修改 `Cargo.toml` 中的依赖版本，除非 spec 明确要求
- 不绕过 `clippy` 规则
- 不使用 `unsafe` 除非有充分理由并在 spec 中声明
- 不使用 `unwrap()` 在生产代码中（使用 `?` 或 `expect()`）

## 指引（必须遵守）
- 遵循 Rust 命名约定：`snake_case` 函数/变量，`PascalCase` 类型
- 错误处理使用 `Result<T, E>` 和 `thiserror`/`anyhow`（按项目实际）
- 使用 trait bounds 而非泛型约束过多
- 保持与项目既有错误处理模式一致

## 测试规则
- 测试放在同模块 `#[cfg(test)]` 或 `tests/` 集成测试目录
- 运行测试：`cargo test`
- 每个 spec 场景至少有一个测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 API | `src/api/` 或 `src/routes/` |
| 新增 Service | `src/services/` 或 `src/` 子模块 |
| 新增 Model | `src/models/` 或 `src/entities/` |
| 测试 | 同模块 `#[cfg(test)]` 或 `tests/` |

## 常见命令
- 测试：`cargo test`
- Lint：`cargo clippy -- -D warnings`
- 构建：`cargo build`
- 格式化：`cargo fmt`
