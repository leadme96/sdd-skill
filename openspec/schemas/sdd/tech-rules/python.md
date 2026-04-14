# Tech Rules: Python

## 边界（禁止事项）
- 不修改 `requirements.txt` / `pyproject.toml` 中的依赖版本，除非 spec 明确要求
- 不绕过项目的 lint 规则（ruff / flake8 / pylint）
- 不使用已废弃的 API 或语法
- 不混用不同风格的代码（保持项目既有风格）

## 指引（必须遵守）
- 遵循 PEP 8 命名约定
- 使用类型注解（保持与项目现有类型注解风格一致）
- 错误处理使用自定义异常或标准异常，不吞异常
- 依赖注入使用构造函数或依赖注入框架（按项目实际）

## 测试规则
- 测试文件放在 `tests/` 目录，`test_*.py` 命名
- 使用项目已有的测试框架（pytest / unittest）
- 运行测试：`pytest` 或 `python -m pytest`
- 每个 spec 场景至少有一个测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 API | `src/api/` 或 `app/routes/`（按项目结构） |
| 新增 Service | `src/services/` 或 `app/services/` |
| 新增 Model | `src/models/` 或 `app/models/` |
| 新增 Config | `src/config/` |
| 测试 | `tests/` 目录，镜像源码结构 |

## 常见命令
- 测试：`pytest` 或 `python -m pytest`
- Lint：`ruff check .` 或 `flake8`
- 类型检查：`mypy .`
- 构建/安装：`pip install -e .`
