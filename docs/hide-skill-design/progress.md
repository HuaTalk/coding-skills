# Progress: /hide Skill 设计进度

## 当前状态: 设计阶段 v3 ✅ | 实现阶段 ⏳

**v3 范围**: 仅 Post-hoc 文件清理。Proactive hiding 进 ROADMAP。

---

## 进度记录

### 2026-06-11 — 调研完成
- ✅ 阅读 `docs/RulesAreForYou/1.md` + `2.md`
- ✅ 调研仓库内 8 个相关 skill 的输出纪律模式
- ✅ 提取 Hidden CoT、Strip Test 等关键模式
- ✅ 输出 `findings.md`

### 2026-06-11 — 设计 v1（双模式 + Hidden CoT）
- ✅ 初始设计: Preventive + Corrective 双模式
- ✅ 三层隐藏模型

### 2026-06-11 — 设计 v2（Hidden CoT + 用户自定义目标）
- ✅ Hidden CoT 机制正式纳入 proactive 核心
- ✅ 用户自定义隐藏目标语法设计

### 2026-06-11 — 设计 v3（缩减范围：仅 Post-hoc File Hiding）
- ✅ 当前范围确定：事后清理文件中泄露的规则引用
- ✅ 三种泄露模式 + 剥离策略
- ✅ 语法简化：`/hide <file>` 或 `/hide`
- ✅ Proactive hiding → ROADMAP.md
- ✅ 更新 `task_plan.md` v3

### 2026-06-11 — 实现完成
- ✅ Step 1: 编写 `skills/hide/SKILL.md`
- ✅ Step 2: 编写 `skills/hide/SKILL-zh.md`
- ✅ Step 6: 更新 ROADMAP.md（#6 — Proactive Hiding）

### 待完成
- ⏳ Step 3: Java 文件清理测试
- ⏳ Step 4: Markdown 文件清理测试
- ⏳ Step 5: 边界情况测试（无泄露文件、混合中英文泄露）

---

## 决策记录

### D1: 当前只做 Post-hoc File Hiding
- **决策**: v1.0 范围仅限事后文件清理
- **理由**: 
  - Post-hoc 是最小可行单元，独立可用
  - Proactive hiding 依赖 Hidden CoT 机制验证，需更多调研
  - 先交付一个能用的，再迭代
- **进 ROADMAP**: Proactive hiding、用户自定义目标、Session 级模式

### D2: 静默执行，不声明清理内容
- **决策**: 清理后不输出 "已移除 X、Y、Z"
- **理由**:
  - 声明清理内容 = 再次泄露（L2: 隐藏隐藏过程）
  - 清理后的文件应该看起来 "本来就是这样写的"
- **风险**: 用户可能想确认清理了什么 → 可对比 git diff

### D3: 仅作用于文件，不作用于 agent 对话回复
- **决策**: `/hide` 只清理文件内容，不修改 agent 的对话输出
- **理由**:
  - 文件是持久化的产物，事后清理有价值
  - 对话回复是瞬时的，事后清理意义有限
  - 清晰的边界让 skill 职责单一

### D4: 只清理注释/文档中的规则引用，不改变代码逻辑
- **决策**: 剥离策略以注释和文档文本为主
- **理由**: 规则泄露几乎都在注释和叙述性文本中，不在可执行代码中
