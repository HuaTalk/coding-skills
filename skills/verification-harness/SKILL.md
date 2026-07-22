---
name: verification-harness
description: 全局验收机制。实现后自动触发：subagent 对抗性 review（bug + 功能漂移）→ 跑测试（单元/集成/e2e）→ linter/type-check → 架构测试 → 结构化 VERDICT 输出。触发：验收、verify、review、检查改动、跑测试、验证、验收流程、acceptance、check changes。
metadata:
  author: HuaTalk
  version: "1.0.1"
  category: workflow
  status: stable
---

# Verification Harness：全局验收机制

**这是一套自动验收流水线，不是代码审查工具。** 目标是在 agent 完成实现后、报告"完成"之前，强制执行多层验证，确保代码真正可用而非"看起来能跑"。

---

## 何时启用

- agent 完成了非平凡改动（3+ 文件编辑、后端/API 变更、基础设施变更）
- 用户说："验收"、"verify"、"检查一下"、"跑测试"、"验证改动"
- 从 prompt-to-merge 自主流程中，实现阶段结束后自动触发

## 何时不用

| 场景 | 做什么 |
|------|--------|
| 单文件小改动（1-2 行） | 直接跑项目测试，不需要完整流水线 |
| 纯文档/注释修改 | 跳过测试，只跑 linter |
| 用户明确说"不用验证" | 尊重用户意愿 |

---

## 阶段 0：项目检测

**在流水线开始前，自动检测项目类型和可用工具。** 读 CLAUDE.md、package.json、pyproject.toml、pom.xml、build.gradle、Makefile 等，填充以下变量：

```
PROJECT_TYPE: python | java-gradle | java-maven | node | go | rust | ruby | mixed
BUILD_CMD: <构建命令>
TEST_CMD: <测试命令>
LINT_CMD: <linter 命令>
TYPE_CHECK_CMD: <type-check 命令，无则留空>
ARCH_TEST_CMD: <架构测试命令，无则留空>
E2E_CMD: <e2e 测试命令，无则留空>
RUNTIME_DEPS: <运行时依赖前置命令，无则留空>
```

### 项目类型检测规则

| 特征 | 项目类型 | 构建 | 测试 | Linter | Type-check | 架构测试 |
|------|---------|------|------|--------|------------|---------|
| `pyproject.toml` / `setup.py` / `requirements.txt` | python | `pip install -e .` 或 `poetry install` | `pytest` | `ruff check` | `mypy` 或 `pyright` | `import-linter` 或 `lint-imports` |
| `pom.xml` | java-maven | `mvn compile` | `mvn test` | `mvn checkstyle:check` | — | `mvn archunit:test` 或 ArchUnit 注解测试 |
| `build.gradle` / `build.gradle.kts` | java-gradle | `./gradlew build` | `./gradlew test` | `./gradlew checkstyleMain` | — | `./gradlew archTest` 或 ArchUnit 注解测试 |
| `package.json` (有 scripts) | node | `npm run build` | `npm test` | `npm run lint` | `npm run typecheck` | — |
| `go.mod` | go | `go build ./...` | `go test ./...` | `golangci-lint run` | — | — |
| `Cargo.toml` | rust | `cargo build` | `cargo test` | `cargo clippy` | — | — |
| `Gemfile` | ruby | `bundle install` | `bundle exec rspec` | `rubocop` | — | — |
| `composer.json` | php | `composer install` | `vendor/bin/phpunit` | `vendor/bin/phpstan` | — | — |
| `*.csproj` / `*.sln` | dotnet | `dotnet build` | `dotnet test` | `dotnet format --verify-no-changes` | — | — |
| 以上都不匹配 | — | 读 CLAUDE.md 或 Makefile 推断 | 同左 | 同左 | 同左 | 同左 |

**项目 CLAUDE.md 优先：** 如果项目 CLAUDE.md 中定义了测试/linter 命令，优先使用项目定义的命令，而非上表默认值。

### 运行时依赖检测

检测以下文件，自动生成 `RUNTIME_DEPS` 前置命令：

| 检测文件 | 前置命令 | 说明 |
|---------|---------|------|
| `docker-compose.yml` / `docker-compose.yaml` | `docker-compose up -d` | 容器化依赖（数据库、Redis 等） |
| `.env` + `docker-compose.yml` | `docker-compose up -d` + 等待健康检查 | 需要环境变量的容器服务 |
| `alembic.ini` | `alembic upgrade head` | Python 数据库迁移 |
| `flyway.conf` | `flyway migrate` | Java 数据库迁移 |
| `prisma/schema.prisma` | `npx prisma migrate deploy` | Node Prisma 迁移 |

**RUNTIME_DEPS 在阶段 1 之前执行。** 如果前置命令失败，VERDICT: FAIL（环境问题阻断流水线）。

### Monorepo 子项目发现

当项目根目录存在以下 workspace 配置时，按配置发现子项目：

| 检测文件 | 子项目发现方式 |
|---------|--------------|
| `pnpm-workspace.yaml` | 按 `packages:` 配置的 glob 模式 |
| `lerna.json` | 按 `packages:` 配置 |
| `nx.json` | 按 `workspace.json` 或 `project.json` |
| Maven reactor (`pom.xml` 有 `<modules>`) | 按 `<modules>` 列表 |
| Gradle multi-project (`settings.gradle`) | 按 `include` 列表 |
| 无 workspace 配置但有多个 `package.json` / `pom.xml` | 检测有独立构建文件的子目录 |

**Monorepo 流水线规则：**
1. 每个子项目独立跑阶段 1-4，独立报告结果
2. 任一子项目阶段 1-3 失败 → 该子项目标记 FAIL，其他子项目继续
3. 最终报告按子项目分段，汇总为：`N 个子项目，M 个 PASS，K 个 FAIL`
4. 阶段 5 对抗性 review 只针对有改动的子项目（基于 git diff 判断）

---

## 阶段输出格式约定

**阶段 1-4 的每个阶段必须输出以下格式，供主 agent 机器解析并填入最终报告：**

```
STATUS: PASS | FAIL | SKIP | WARN
SUMMARY: <一句话摘要>
DETAILS: <结构化数据，如 passed/failed/skipped 数量>
```

**示例：**

```
# 阶段 3 单元测试
STATUS: PASS
SUMMARY: 423 passed, 1 skipped, 2 warnings
DETAILS: PASSED=423 FAILED=0 SKIPPED=1 WARNINGS=2 DURATION=12.3s

# 阶段 2 Linter（有警告但不阻断）
STATUS: WARN
SUMMARY: 3 style warnings auto-fixed
DETAILS: WARNINGS=3 AUTO_FIXED=3 BLOCKING_ERRORS=0

# 阶段 4 E2E 测试（未配置）
STATUS: SKIP
SUMMARY: E2E_CMD not configured
DETAILS: REASON=no_e2e_command
```

**状态判定规则：**
- `PASS` — 命令执行成功，退出码 0
- `FAIL` — 命令执行失败或退出码非 0（阻断性错误）
- `SKIP` — 命令未配置或不适用
- `WARN` — 命令执行成功但有非阻断性警告

---

## 阶段 1：构建检查

```
运行 BUILD_CMD
如果失败 → VERDICT: FAIL（构建失败是自动 FAIL，不进入后续阶段）
```

---

## 阶段 2：Linter + Type-checker

```
运行 LINT_CMD
如果失败：
  - 有 --fix 选项 → 尝试自动修复 → 重新运行验证修复成功
  - 无 --fix 或修复后仍失败 → 检查错误类型：
    - 语法错误 / 导入错误 → VERDICT: FAIL（阻断性错误）
    - 风格警告 / 非阻断性警告 → 记录警告，继续流水线
运行 TYPE_CHECK_CMD（如果存在）
如果失败 → VERDICT: FAIL（类型错误是阻断性错误）
```

**关键：Linter 必须输出可执行的修复指令。** 如果 linter 只报行号和错误码，agent 无法自动修复。优先选择能输出修复建议的 linter（如 ruff、eslint --fix）。

---

## 阶段 3：单元测试

```
运行 TEST_CMD
如果失败 → VERDICT: FAIL（测试失败是自动 FAIL）
记录通过/失败/跳过数量
```

**测试结果是"上下文，不是证据"。** 测试通过 ≠ 验证通过。后续阶段必须独立验证。

---

## 阶段 4：集成 + E2E 测试

```
如果有 E2E_CMD → 运行 E2E_CMD
如果有快照测试 → 运行快照测试
如果有架构测试 → 运行 ARCH_TEST_CMD
记录结果
```

### 快照测试（推荐添加）

快照测试是检测功能漂移的最轻量手段。如果项目没有快照测试，建议在 CLAUDE.md 中记录：
```
# 建议添加快照测试锁定 API 响应形状
```

### 架构测试（推荐添加）

架构测试验证模块边界不被跨越。按项目类型：

| 项目类型 | 工具 | 检查内容 |
|---------|------|---------|
| Java | ArchUnit | 分层架构、包依赖规则、命名约定 |
| Python | import-linter | 模块导入边界、分层约束 |
| Node | eslint-plugin-import | 导入规则、路径限制 |

---

## 阶段 5：对抗性 Subagent Review

**这是流水线的核心。** 前 4 个阶段是自动化检查，本阶段是 AI 驱动的深度验证。

### 5.1 派出 Review Subagent

使用 Agent tool 派出一个 **只读、对抗性** 的 review subagent。

> **下面的 prompt 整块传给 subagent，不要拆分。** 它是独立的、自包含的指令。

---

**[SUBAGENT PROMPT START — 传给 Agent tool 的 prompt]**

你是验收专家。你的工作不是确认实现能用——而是尝试打破它。

=== 绝对禁止修改项目 ===
你被严格禁止：
- 在项目目录中创建、修改、删除任何文件
- 安装依赖或包
- 运行 git 写操作（add、commit、push）
你可以在 /tmp 或 $TMPDIR 写临时测试脚本。

=== 你收到的信息 ===
主 agent 会用以下格式传入信息，用 === 分隔：

=== TASK ===
<原始任务描述>
=== FILES ===
<修改的文件列表，每行一个>
=== APPROACH ===
<采用的方法>
=== TEST COMMANDS ===
<项目 CLAUDE.md 中的测试命令>

=== 验证策略 ===
根据改动类型调整策略：

**前端改动**: 启动开发服务器 → 用浏览器工具导航、截图、点击、读控制台 → curl 子资源 → 跑前端测试
**后端/API 改动**: 启动服务器 → curl/fetch 端点 → 验证响应形状（不只是状态码）→ 测试错误处理 → 边界情况
**CLI/脚本改动**: 用代表性输入运行 → 验证 stdout/stderr/exit code → 边界输入（空、畸形、边界值）→ 验证 --help
**基础设施/配置改动**: 验证语法 → dry-run → 检查 env vars/secrets 是否真的被引用
**库/包改动**: 构建 → 完整测试 → 从新上下文导入并作为消费者使用公共 API → 验证导出类型匹配文档
**Bug 修复**: 复现原始 bug → 验证修复 → 跑回归测试 → 检查相关功能是否有副作用
**重构（无行为变更）**: 现有测试必须原样通过 → diff 公共 API 表面 → 抽查可观测行为是否一致

=== 反合理化 ===
你会想跳过检查。以下是你常用的借口——识别它们并做相反的事：
- "代码看起来正确" — 阅读不是验证，必须运行
- "实现者的测试已通过" — 实现者是 LLM，必须独立验证
- "这应该没问题" — "应该"不是"已验证"
- "我没有浏览器" — 先检查有没有 MCP 工具
- "这太耗时了" — 不是你的决定
如果你发现自己在写解释而不是命令，停下来。运行命令。

=== 对抗性探测 ===
功能测试确认 happy path。还要尝试打破它。按改动类型选择性执行：

| 探测类型 | 适用场景 | 不适用场景 |
|---------|---------|-----------|
| **并发** | 服务器/API、有状态服务 | CLI 脚本、纯库、静态站点 |
| **边界值** | 所有场景（通用） | — |
| **幂等性** | API 的 create/update/delete | 只读操作、一次性脚本 |
| **孤儿操作** | 有引用关系的资源 | 无外部依赖的独立模块 |

- **并发**：并行请求 create-if-not-exists 路径 — 重复 session？丢失写入？
- **边界值**：0, -1, 空字符串, 超长字符串, unicode, MAX_INT
- **幂等性**：同一变更请求发两次 — 重复创建？错误？正确的 no-op？
- **孤儿操作**：删除/引用不存在的 ID

跳过不适用的探测时，在报告中注明：`Probe [类型]: SKIPPED (reason: 不适用于 CLI 脚本)`

=== 输出格式（必须遵守）===
每个检查必须包含以下结构。没有 Command run 块的检查不是 PASS——是跳过。

### Check: [验证什么]
**Command run:**
  [执行的确切命令]
**Output observed:**
  [实际终端输出——复制粘贴，不要改写]
**Result: PASS** (或 FAIL — 附 Expected vs Actual)

末尾必须有这行（机器解析）：
VERDICT: PASS
或
VERDICT: FAIL
或
VERDICT: PARTIAL

PARTIAL 仅用于环境限制（没有测试框架、工具不可用、服务器无法启动）。

**[SUBAGENT PROMPT END]**

### 5.2 收到 VERDICT 后的处理

| VERDICT | 行为 |
|---------|------|
| **PASS** | 主 agent 抽查 verifier 报告中的 2-3 个命令（重新运行确认输出一致） |
| **FAIL** | 主 agent 修复问题 → 重新派出 verifier → 重复直到 PASS |
| **PARTIAL** | 报告哪些通过了、哪些无法验证、为什么无法验证 |

### 5.3 FAIL → 修复 → 重新验证循环

```
while verdict != PASS:
    1. 收到 FAIL 报告
    2. 主 agent 修复报告中的问题
    3. 重新派出 verifier（传入修复后的文件列表）
    4. 收到新的 VERDICT
    if 循环次数 > 3:
        报告给用户，请求指导
```

---

## 最终报告

流水线结束后，输出结构化报告。

### 单项目报告格式

```
## 验收报告

### 运行时依赖：✅ PASS / ❌ FAIL / ⏭️ 跳过（无依赖）
### 构建：✅ PASS / ❌ FAIL
### Linter：✅ PASS / ⚠️ N 个警告（已自动修复 M 个）/ ❌ FAIL
### Type-check：✅ PASS / ❌ FAIL / ⏭️ 跳过（未配置）
### 单元测试：✅ PASS（N passed, M skipped）/ ❌ FAIL
### 集成测试：✅ PASS / ❌ FAIL / ⏭️ 跳过
### E2E 测试：✅ PASS / ❌ FAIL / ⏭️ 跳过
### 架构测试：✅ PASS / ❌ FAIL / ⏭️ 跳过
### 对抗性 Review：✅ PASS / ❌ FAIL / ⚠️ PARTIAL

### VERDICT: PASS / FAIL / PARTIAL

### 失败详情（如有）：
- [具体失败项 + 修复建议]
```

### Monorepo 报告格式

```
## 验收报告（Monorepo）

### 汇总：N 个子项目，M 个 PASS，K 个 FAIL

### [子项目 1: frontend]
#### 构建：✅ PASS
#### Linter：✅ PASS
#### 单元测试：✅ PASS（N passed）
#### 对抗性 Review：✅ PASS
#### VERDICT: PASS

### [子项目 2: backend]
#### 构建：✅ PASS
#### Linter：⚠️ 2 个警告
#### 单元测试：❌ FAIL（3 failed）
#### 对抗性 Review：⏭️ 跳过（单元测试未通过）
#### VERDICT: FAIL
#### 失败详情：
- test_user_login: Expected 200, got 500

### 总 VERDICT: FAIL（1/2 子项目失败）
```

---

## 典型场景

### 场景：Python 项目 Pydantic AI 迁移（english-story-learner）

**背景：** 36 文件改动，LangChain → Pydantic AI 全量迁移。

**流水线执行：**

```
阶段 0 检测：pyproject.toml 存在 → PROJECT_TYPE=python
             BUILD_CMD=pip install -e .
             TEST_CMD=pytest
             LINT_CMD=ruff check
             TYPE_CHECK_CMD=mypy
             ARCH_TEST_CMD=pytest tests/architecture/
             RUNTIME_DEPS=（无）

阶段 1 构建：pip install -e .
  STATUS: PASS
  SUMMARY: build succeeded
  DETAILS: EXIT_CODE=0

阶段 2 Linter：ruff check → 3 个警告（magic strings）→ --fix 自动修复 → 重新运行
  STATUS: WARN
  SUMMARY: 3 style warnings auto-fixed
  DETAILS: WARNINGS=3 AUTO_FIXED=3 BLOCKING_ERRORS=0

阶段 3 单元测试：pytest → ❌ FAIL（TestModel 兼容性问题，ctx.metadata 为 None）
  → 主 agent 修复 _before_model_request 和 _on_run_error
  → 重新运行：
  STATUS: PASS
  SUMMARY: 423 passed, 1 skipped, 2 warnings
  DETAILS: PASSED=423 FAILED=0 SKIPPED=1 WARNINGS=2 DURATION=12.3s

阶段 4 架构测试：pytest tests/architecture/ → ❌ FAIL（API 层直接导入 domain service）
  → 主 agent 将 get_vision_story_composer 从 service.py 移到 ports.py
  → 重新运行：
  STATUS: PASS
  SUMMARY: 5 architecture tests passed
  DETAILS: PASSED=5 FAILED=0

阶段 5 对抗性 Review：
  === TASK ===
  Migrate LangChain to Pydantic AI with type-safe agents
  === FILES ===
  backend/agents/*.py, backend/domains/story/service.py, ...
  === APPROACH ===
  Replace LangChain chains with Pydantic AI Agent objects
  === TEST COMMANDS ===
  pytest, pytest tests/architecture/

  → Check: 边界值输入（空故事、超长文本）→ PASS
  → Check: 并发请求同一故事 → PASS
  → Check: 迁移前后 API 响应形状对比 → PASS
  → Probe [幂等性]: SKIPPED (reason: migration is one-time operation)
  → VERDICT: PASS

## 验收报告
### 运行时依赖：⏭️ 跳过（无依赖）
### 构建：✅ PASS
### Linter：⚠️ 3 个警告（已自动修复）
### Type-check：✅ PASS
### 单元测试：✅ PASS（423 passed, 1 skipped）
### 集成测试：⏭️ 跳过
### E2E 测试：⏭️ 跳过
### 架构测试：✅ PASS
### 对抗性 Review：✅ PASS
### VERDICT: PASS
```

**关键点：** 阶段 3 和 4 各发现一个问题，修复后重新验证通过。如果没有流水线，这两个问题会在部署后才暴露。

---

## 反模式

| 不要做 | 应该做 |
|--------|--------|
| ❌ 跑完测试就报告"验证通过" | ✅ 测试是上下文，不是证据；必须有对抗性 review |
| ❌ 让 reviewer 能修改代码 | ✅ reviewer 必须只读，否则会倾向于"帮你修了"而不是"报 FAIL" |
| ❌ 纯靠读代码判定 PASS | ✅ 每个 PASS 必须有 Command run + Output observed |
| ❌ 被前 80% 迷惑（精美 UI + 通过的测试） | ✅ 重点检查最后 20%（边界、错误处理、状态持久化） |
| ❌ 同一个失败重试 3 次以上 | ✅ 3 次失败后升级给用户 |
| ❌ 不记录失败原因 | ✅ 每个失败必须有 Expected vs Actual |
