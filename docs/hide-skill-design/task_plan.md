# Task Plan: /hide Skill 设计 v3

## 概述

`/hide` — 事后清理**文件**中泄露的规则引用、上下文复读、约束道歉。

**作用域**: 仅作用于生成的文件/代码/文档内容。**不作用于 agent 对话回复本身。**

**当前范围（v1.0）**:
- Post-hoc 文件清理：扫描指定文件，剥离规则泄露内容，写回纯净版本
- 内置三种泄露模式识别（规则引用/上下文复读/约束道歉）
- 静默执行（不声明"已清理"、不解释"清理了什么"）

**不在当前范围（进 ROADMAP）**:
- Proactive hiding（Hidden CoT 事前预防）
- Session 级 hide 模式
- 用户自定义隐藏目标
- `/hide:clean` 对话级清理

---

## Phase 1: 核心设计

### 1.1 调用语法

```
/hide <file>        → 清理指定文件中的规则泄露
/hide               → 清理当前上下文中的文件（如果正在编辑）
```

### 1.2 工作流程

```
用户: /hide src/main/java/com/example/UserService.java

AI:
  1. 读取文件内容
  2. 在 internal reasoning 中扫描三种泄露模式
  3. 剥离匹配的泄露内容（保留代码逻辑不变）
  4. 写回文件
  5. 不声明"已清理"、不列举"移除了什么"
```

### 1.3 三种泄露模式

| 模式 | 匹配规则 | 示例 |
|------|---------|------|
| TYPE A — 规则引用 | "根据/按照/遵循/基于 [规则源]"、"as instructed"、"following the convention"、"according to CLAUDE.md" | `// 根据 CLAUDE.md 的指示，使用 JUnit 5` → 删除注释 |
| TYPE B — 上下文复读 | "从文档中回想起"、"架构文档中说"、"代码库遵循 X 模式"、"I recall from the docs" | `// 架构文档中提到这里应该用工厂模式` → 删除注释 |
| TYPE C — 约束道歉 | "因为团队使用 X 所以不能用 Y"、"由于规范要求"、"I can't use X because" | `// 不能使用 Mockito，因为团队标准是 JMockit` → 删除注释 |

### 1.4 剥离策略

```
对于代码文件（.java, .py, .ts, .go 等）:
  - 删除包含泄露的注释行
  - 保留代码语句（import、方法调用等）不变
  - 如果整段注释都是规则解释 → 整段删除

对于 Markdown 文件（.md）:
  - 删除泄露段落
  - 保留纯技术性内容

对于配置文件（.yml, .json, .xml 等）:
  - 删除包含泄露的注释
  - 配置值不变
```

---

## Phase 2: SKILL.md 核心指令

```
## /hide — Post-hoc File Cleanup

When invoked with a file path:

1. Read the target file.
2. In your internal reasoning only, scan for three leakage patterns:
   - TYPE A: Rule citations ("according to CLAUDE.md", "基于规则",
     "following the convention", "as instructed", "per guidelines")
   - TYPE B: Context echoes ("从文档中回想起", "架构文档中说",
     "I recall from the docs", "the codebase follows")
   - TYPE C: Constraint apologies ("不能使用 X 因为团队用 Y",
     "I can't use X because", "由于规范要求")
3. Strip matched content:
   - For code: remove comment lines containing leakage, keep code unchanged
   - For markdown: remove leakage paragraphs, keep technical content
   - For config: remove leakage comments, keep config values
4. Write the cleaned content back to the file.
5. SILENT. Do NOT:
   - Announce what was removed
   - List cleaned items
   - Say "file cleaned" or "/hide applied"
   - Add cleanup markers to the file
   The cleaned file should look like it was written that way originally.
```

---

## Phase 3: Before/After

### 示例 1：Java 文件

**Before** (`UserService.java`):
```java
// 根据 CLAUDE.md 的指示，使用 given-when-then 模式
@Test
void findUser_returnsUserWhenExists() {
    // given: 准备 mock 数据（遵循团队 Mockito 规范）
    when(repo.findById(1L)).thenReturn(Optional.of(testUser));
    
    // when: 执行被测方法
    var result = service.findUser(1L);
    
    // then: 验证结果 — 根据代码库约定使用 assertThat
    assertThat(result).isEqualTo(testUser);
}
```

**After** (`/hide` 清理后):
```java
@Test
void findUser_returnsUserWhenExists() {
    when(repo.findById(1L)).thenReturn(Optional.of(testUser));
    
    var result = service.findUser(1L);
    
    assertThat(result).isEqualTo(testUser);
}
```

### 示例 2：Markdown 文件

**Before** (`docs/design.md`):
```markdown
## 架构设计

根据架构文档 `architecture/decisions.md` 的约定，这里使用三层架构。
从 ADR-003 中我们知道，数据层使用 Repository 模式。

### 服务层
...
```

**After** (`/hide` 清理后):
```markdown
## 架构设计

### 服务层
...
```

---

## Phase 4: 文件结构

```
skills/hide/
├── SKILL.md          # 英文主文件
└── SKILL-zh.md       # 中文变体
```

---

## Phase 5: 实现路线图

| 步骤 | 内容 |
|------|------|
| Step 1 | 编写 `skills/hide/SKILL.md` |
| Step 2 | 编写 `skills/hide/SKILL-zh.md` |
| Step 3 | 场景测试 — Java 文件清理 |
| Step 4 | 场景测试 — Markdown 文件清理 |
| Step 5 | 场景测试 — 边界情况（无泄露的文件、混合中英文泄露） |
| Step 6 | 更新 ROADMAP.md（记录 proactive hiding 等未来功能） |

---

## Phase 6: 不在当前范围（ROADMAP 记录）

以下功能明确不在 v1.0 范围，写入 `ROADMAP.md` 供后续实现：

1. **Proactive Hiding（Hidden CoT）**: 在会话开始前建立隐藏规则，AI 在 internal reasoning 中处理规则，visible output 绝不泄露
2. **用户自定义隐藏目标**: `/hide mock_data` 等自然语言描述的自定义隐藏类别
3. **Session 级 `/hide` 模式**: `/hide` 作为持续模式而非一次性命令
4. **`/hide:clean` 对话级清理**: 清理上一轮对话输出中的泄露
5. **`/hide:off` 退出机制**: 通过 `/handoff` 或新 session 退出
