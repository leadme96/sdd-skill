# Tech Rules: Java

## 边界（禁止事项）
- 不修改 `pom.xml` / `build.gradle` 中的依赖版本，除非 spec 明确要求
- 不绕过项目的代码风格检查（Checkstyle / SpotBugs）
- 不使用已废弃的 API
- 不修改与当前 spec 无关的包

## 指引（必须遵守）
- 遵循 Java 命名约定：`PascalCase` 类名，`camelCase` 方法/变量
- 使用依赖注入（Spring DI 或项目使用的框架）
- 异常处理：检查异常用于可恢复错误，运行时异常用于编程错误
- 保持与项目现有框架和风格一致

## 测试规则
- 测试文件放在 `src/test/java/`，镜像源码包结构
- 使用项目已有的测试框架（JUnit 5 / TestNG）
- 运行测试：`mvn test` 或 `gradle test`
- 每个 spec 场景至少有一个测试用例

## 变更落点
| 变更类型 | 落点目录 |
|----------|----------|
| 新增 Controller/API | `src/main/java/.../controller/` |
| 新增 Service | `src/main/java/.../service/` |
| 新增 Model/Entity | `src/main/java/.../model/` 或 `.../entity/` |
| 新增 Repository | `src/main/java/.../repository/` 或 `.../mapper/` |
| 测试 | `src/test/java/` 镜像源码结构 |

## 常见命令
- 测试：`mvn test` 或 `gradle test`
- 构建：`mvn clean package` 或 `gradle build`
- Lint：`mvn checkstyle:check`
