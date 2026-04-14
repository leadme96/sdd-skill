# Tech Rules: Go

## 边界（禁止事项）
- 不修改 `go.mod` 中的依赖版本，除非 spec 明确要求
- 不绕过 `go fmt` 和 `go vet` 规则
- 不引入循环依赖
- 不使用 `panic()` 处理业务错误（仅用于不可恢复错误）
- 不修改与当前 spec 无关的包

## 指引（必须遵守）
- 遵循 Go 命名约定：`snake_case` 包名，`CamelCase` 导出标识符
- 接口定义在使用方（accept interfaces, return structs）
- 错误处理使用 `fmt.Errorf("context: %w", err)` 包装
- 使用 `context.Context` 传递超时和取消信号
- 依赖注入使用构造函数

## 测试规则
- 测试文件放在同目录，`*_test.go` 命名
- 使用标准 `go test` + 表驱动测试
- 运行测试带 `-race` 标志：`go test -race ./...`
- 每个 spec 场景至少有一个测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 API Handler | `internal/handler/` 或 `cmd/`（按项目结构） |
| 新增 Service | `internal/service/` 或 `pkg/` |
| 新增 Model/Entity | `internal/model/` 或 `pkg/` |
| 新增 Repository | `internal/repository/` |
| 测试 | 同目录 `*_test.go` |

## 常见命令
- 测试：`go test -race ./...`
- Lint：`golangci-lint run ./...`
- 构建：`go build ./...`
- 格式化：`gofmt -w .`
