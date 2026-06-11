# Skill 原子化改造指南

## 现状：引用关系拓扑

```
brainstorming  ←── light-explore, explore-legacy, unknown-unknowns, best-effort-delivery, domain-context
light-explore  ←── best-effort-delivery, unknown-unknowns, skill-simplifier
domain-context ←── best-effort-delivery, skill-simplifier
handoff        ←── best-effort-delivery, domain-context
```

共 **19 条交叉引用**，分三类：边界/对比（~60%）、升级路径（~25%）、真正委托（1处）。

---

## 三类引用与改造策略

### 类型一：边界/对比引用

> 一个 skill 在"何时用我 vs 用 X"里点名其他 skill。

**典型例子：**

| 源 skill | 代码 |
|---|---|
| `light-explore` | "0个未知=直接做，1-2个未知=用我，3+个未知=用 brainstorming" |
| `unknown-unknowns` | 一整张"与其他技能的关系"表，列出 5 个 skill |
| `explore-legacy` | "如果是新功能，不要用我，用 brainstorming" |
| `best-effort-delivery` | "当需要基于对话的澄清时用 brainstorming，当用户说别问我时用我" |

**问题：** 把 skill 串成一条"认知复杂度"链。新增一个 skill（如 `medium-explore`）需要改动 ~5 个文件的对比说明。skill 名称重命名时产生大量联动修改。

**改造方式：** 把"何时用我"的判断标准**内化**为自身特征描述，不点名其他 skill。

```markdown
# 耦合写法
Use light-explore when requirements are ~80% clear. If fuzzier, use brainstorming.

# 原子化写法
Use light-explore when 1-2 key decision points are still open — the goal is clear
but a few implementation choices remain unresolved.
```

**核心原则：描述自己的适用场景边界，不评价其他 skill 的适用场景。**

---

### 类型二：升级路径引用

> 告诉 agent "如果我不适用，你应该换用 Y"。

**典型例子：**

| 源 skill | 代码 |
|---|---|
| `light-explore` → `openspec-new-change` | "当需要正式文档和团队评审时，用 openspec-new-change" |
| `explore-legacy` → `brainstorming` | "当被要求构建时，切换到 brainstorming/light-explore" |
| `unknown-unknowns` → `openspec-explore` | "可以先 nudge 盲点，然后进入 openspec-explore" |

**问题：** 每个 skill 在内部定义了一个"路由规则"，路由逻辑散落在各处，且指向的具体 skill 名称为硬编码。

**改造方式：** 描述**升级条件**而非目标 skill 名称。让调用方（用户或路由逻辑）做决策。

```markdown
# 耦合写法
If the change needs formal documentation and team review, use openspec-new-change.

# 原子化写法
If the change needs formal documentation and team review, escalate to a structured
change proposal process with peer review and artifact generation.
```

---

### 类型三：真正委托（仅 1 处，最需要解决）

> `best-effort-delivery` 在捕获场景中调用 `[[domain-context]]` 的"重架构、轻细节"纪律。

**这是唯一的运行时功能依赖。** best-effort-delivery 的 Step 3 明确引用 domain-context 的规则来捕获领域知识。

**改造方式：** 把 domain-context 的捕获规则提取为 best-effort-delivery 自身的内部步骤，不依赖外部 skill 存在。

---

## 改造优先级

| 优先级 | 改动 | 影响 |
|---|---|---|
| **P0** | `best-effort-delivery` 解除对 `domain-context` 的委托依赖 | 唯一的运行时耦合 |
| **P1** | `light-explore` 移除对 `brainstorming` / `openspec-new-change` 的引用 | 3 处引用 |
| **P1** | `unknown-unknowns` 移除"与其他技能的关系"整张表 | 5 处引用 |
| **P2** | `explore-legacy` 移除 `brainstorming` / `light-explore` 引用 | 2 处引用 |
| **P2** | `skill-simplifier` 移除对 `domain-context` / `skill-writer` 等分类示例引用 | 5 处引用 |
| **P3** | `domain-context` 移除对其他技能的边界说明 | 2 处引用 |
| — | `openspec-explore` / `handoff` / `brainstorming` | 已原子化，无需改动 |

---

## 改造前后的 skill 结构对比

### 当前（有耦合）

```
SKILL.md 包含:
  - 自身能力描述
  - 对 2~5 个其他 skill 的对比/升级引用  ← 耦合点
  - 自身流程/示例
```

### 目标（原子化）

```
SKILL.md 包含:
  - 一句话定位：我解决什么问题
  - 触发条件：什么场景下用我（自描述，不提及他人）
  - 不适用场景：超出我能力边界的条件（描述条件，不指定去用谁）
  - 自身流程/示例
  - 相关资源（可选，仅列出自身依赖的文件/模板）
```

---

## 补充建议

1. **brainstorming 是好的参考模板**：被 5 个 skill 引用但不引用任何其他 skill。可以把它作为原子化 skill 的结构范本。

2. **如果未来 skill 数量继续增长**：考虑引入一个独立的 `skill-router` 负责"选择哪个 skill"，让每个 skill 只描述自己能做什么、不能做什么。路由逻辑集中在一个地方。

3. **skill-simplifier 中的分类示例引用**：这些引用是教学性质的（"例如 domain-context 是一个路由器类型 skill"），可以改为描述类型特征而不点名具体 skill。
