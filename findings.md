# 发现与决策

## 需求

对 `skills/` 下的 9 个 skill 做原子化改造，消除所有交叉引用，让每个 skill 完全自包含。

## 研究发现

### 引用关系拓扑（共 19 条交叉引用）

```
brainstorming  ←── light-explore, explore-legacy, unknown-unknowns, best-effort-delivery, domain-context
light-explore  ←── best-effort-delivery, unknown-unknowns, skill-simplifier
domain-context ←── best-effort-delivery, skill-simplifier
handoff        ←── best-effort-delivery, domain-context
```

### 引用分类

| 类型 | 占比 | 性质 | 改造方式 |
|------|------|------|---------|
| 边界/对比 | ~60% | "何时用我 vs 用 X" | 内化判断标准为自描述 |
| 升级路径 | ~25% | "我不适用时换用 Y" | 描述升级条件而非目标 skill |
| 真正委托 | 1 处 | best-effort-delivery → domain-context | 内化被委托的规则 |

### 各 skill 耦合详情

| 源 skill | 引用的目标 skill | 引用方式 | 行位置 |
|-----------|-----------------|---------|--------|
| **best-effort-delivery** | domain-context | `[[domain-context]]` ×2 | L53, L110 |
| | handoff | `[[handoff]]` ×1 | L60 |
| | brainstorming | `[[brainstorming]]` ×1 | L111 |
| | light-explore | `[[light-explore]]` ×1 | L111 |
| **light-explore** | brainstorming | 显式名称 ×3 | L4, L20, L39 |
| | openspec-new-change | 显式名称 ×1 | L22 |
| **unknown-unknowns** | brainstorming | "与其他技能关系"表 | L189-198 |
| | light-explore | 同上 | 同上 |
| | explore-legacy | 同上 | 同上 |
| | openspec-explore | 同上 | 同上 |
| | best-effort-delivery | 同上 | 同上 |
| **explore-legacy** | brainstorming | 显式名称 ×2 | L28, L201 |
| | light-explore | 显式名称 ×2 | L29, L201 |
| **skill-simplifier** | domain-context | 分类示例 + 边界 | L24, L118 |
| | light-explore | 分类示例 | L26 |
| | skill-writer | 边界 | L115 |
| | simplify | 边界 | L116 |
| | humanizer-zh | 边界 | L117 |
| **domain-context** | handoff | 边界说明 | L158 |
| | best-effort-delivery | 边界说明 | L159 |

### 已原子化（无需改动）

- `brainstorming`：被 5 个引用但不引用任何其他 skill
- `handoff`：仅通用提及"建议的技能"，不点名
- `openspec-explore`：仅依赖外部 openspec CLI，不引用其他 skill

## 技术决策

| 决策 | 理由 |
|------|------|
| P0-P3 分 6 阶段改造 | 按耦合严重度排序，先解决运行时依赖，再清理文档引用 |
| 描述条件而非点名 | 新增 skill 不需要改 5 个文件 |
| 同步改 SKILL-zh.md | 中英文必须一致 |
| 不改 frontmatter `name` | 改名等于替换 skill，破坏已有安装 |
| 不删 `[[other-skill]]` 通用模式 | 这是 skill-simplifier 的压缩保护规则，不是具体引用 |

## 视觉/浏览器发现

- 无需视觉确认（纯文本编辑任务）
