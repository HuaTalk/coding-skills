# 任务计划：Skill 原子化改造

## 目标

消除 `skills/` 下所有 skill 之间的交叉引用，让每个 skill 完全自包含（可独立安装使用，不假设其他 skill 存在）。

## 当前阶段

阶段 1

## 各阶段

### 阶段 1：P0 — best-effort-delivery 解除对 domain-context 的委托依赖
- [ ] 分析 best-effort-delivery SKILL.md 中 4 处 `[[skill]]` 引用
- [ ] `[[domain-context]]`（2 处）：内化"重架构、轻细节"纪律为自身步骤，不再委托
- [ ] `[[handoff]]`（1 处）：保留临时文件模式描述，但不点名 handoff
- [ ] `[[brainstorming]]` / `[[light-explore]]`（1 处）：改为自描述的互斥条件
- [ ] 同步修改 SKILL-zh.md 对应段落
- **状态：** pending

### 阶段 2：P1 — light-explore 移除升级路径引用
- [ ] 移除 "Use brainstorming instead" → 改为描述不适用条件
- [ ] 移除 "Use openspec-new-change" → 改为描述升级条件（正式文档+团队评审）
- [ ] 移除 "Relationship to Other Skills" 整节
- [ ] 改 `description` frontmatter：移除 "Use brainstorming for..." 等对比引用
- [ ] 同步修改 SKILL-zh.md
- **状态：** pending

### 阶段 3：P1 — unknown-unknowns 移除"与其他技能关系"表
- [ ] 移除 "Relationship to Other Skills" 整张表（列出 5 个 skill）
- [ ] 检查 body 中其他提及 skill 名的地方："that's brainstorming's job" 等
- [ ] 改为自描述：`brainstorming` → "full alternatives analysis"，`light-explore` → "known-detail clarification"
- [ ] 同步修改 SKILL-zh.md
- **状态：** pending

### 阶段 4：P2 — explore-legacy 移除升级路径引用
- [ ] 移除 "When NOT to Use" 表中对 `brainstorming` / `light-explore` 的点名
- [ ] 移除 Guardrails 中对 `brainstorming` / `light-explore` 的点名
- [ ] 改为描述切换条件而非目标 skill
- [ ] 同步修改 SKILL-zh.md
- **状态：** pending

### 阶段 5：P2 — skill-simplifier 移除分类示例引用
- [ ] 移除 "Three Skill Types" 示例列中对 `domain-context` / `light-explore` 的点名
- [ ] 移除 "Boundaries" 节对 `skill-writer` / `simplify` / `humanizer-zh` / `domain-context` 的点名
- [ ] 改为特征描述：router-type skill、protocol-type skill 等
- [ ] 保留 `[[other-skill]]` 作为压缩保护规则的**通用模式描述**（不是具体引用）
- [ ] 同步修改 SKILL-zh.md
- **状态：** pending

### 阶段 6：P3 — domain-context 移除边界说明
- [ ] 移除 "Boundaries with Other Skills" 节（handoff / best-effort-delivery）
- [ ] 改为自描述的边界条件
- [ ] 同步修改 SKILL-zh.md
- **状态：** pending

### 阶段 7：验证
- [ ] 确认改造后 6 个 skill 无任何 `[[skill-name]]` 维基链接指向其他 skill
- [ ] 确认改造后 6 个 skill 无任何显式 skill 名称引用（brainstorming, light-explore, domain-context 等）
- [ ] 确认 3 个已原子化 skill（openspec-explore, handoff, brainstorming）未被误改
- [ ] 确认所有 `SKILL-zh.md` 与对应 `SKILL.md` 改造一致
- [ ] `wc -lc` 检查改造后的行数/字节变化
- **状态：** pending

## 已有决策

| 决策 | 理由 |
|------|------|
| 不引入 skill-router | 当前 skill 数量（9 个）不需要额外路由层，原子化足以解决问题 |
| 保留 `[[other-skill]]` 通用模式描述 | skill-simplifier 的 `[[other-skill]]` 是压缩保护规则的教学示例，不是具体引用 |
| 同步改造 SKILL-zh.md | 中英文必须一致，否则语言切换后耦合仍然存在 |
| `description` frontmatter 中的 skill 名也要改 | frontmatter 被 dispatcher 读取，同样需要自包含 |

## 备注

- 参考依据：`docs/skill-atomicity-guide.md`
- 改造原则：描述自身特征，不评价其他 skill；描述升级条件，不指定目标 skill 名
- 每个阶段完成后更新 progress.md
- SKILL.md 和 SKILL-zh.md 的改造必须同步，防止语言切换后引用断裂
