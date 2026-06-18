# Findings: /hide Skill 调研发现

## 1. 核心理念来源

### "Rules Are for You, Not the Output" 哲学
- **来源**: `blog-rules-are-for-you.md` + `docs/RulesAreForYou/1.md` + `docs/RulesAreForYou/2.md`
- **核心原则**: 规则描述 AI **如何思考**，而非 AI **应该说什么**。规则服务于 AI 的决策，绝不泄露到输出中。
- **两个受众模型**:
  1. Claude 决策引擎 — 需要知道用什么工具、遵循什么模式
  2. 人类开发者 — 只需要看到结果，不需要看到引用了哪条规则

### 三种规则泄露模式（反模式）
| 模式 | 表现 | 正确做法 |
|------|------|----------|
| 规则引用 | "根据 CLAUDE.md 的指示..." | 闭嘴，直接给格式化结果 |
| 上下文复读 | "我从架构文档中回想起..." | 用理解指导决策，不做 narration |
| 约束道歉 | "我不能用 Mockito，因为团队标准是..." | 直接用 JMockit，import 语句说明一切 |

## 2. 现有相关 Skill 模式

### 2.1 Hidden CoT 模式（最关键 —— Proactive Hiding 的核心机制）
- **来源**: `docs/RulesAreForYou/1.md:50-51`
- **机制**: 强制模型在内部思维链中处理规则（重构规则、权衡框架），只在可见输出中交付最终结果。内部推理对用户不可见。
- **适用性**: 这是 proactive hiding 的核心技术手段，Claude Code 中 AI 的 internal reasoning 已默认对用户隐藏
- **关键洞察**: Claude Code 的 AI 本身就有 internal reasoning（用户不可见）和 visible output（用户可见）两层。问题在于 AI 有时把规则处理写到了 visible output 中。`/hide` 的作用就是建立严格边界：规则处理 → internal reasoning，结果交付 → visible output

### 2.2 best-effort-delivery 的二分法
- **来源**: `skills/best-effort-delivery/SKILL.md:25-34`
- **机制**: 高置信度直接落地到源文件，低置信度归集到 HTML 待确认文档
- **借鉴点**: 输出路由策略 — 不同内容走不同通道。类似地，`/hide` 把 "规则推理" 路由到 Hidden CoT，把 "结果" 路由到 visible output

### 2.3 unknown-unknowns 的 "一次轻推，然后闭嘴"
- **来源**: `skills/unknown-unknowns/SKILL.md:96-101`
- **机制**: 一次性把感知差距摆在桌面上，然后闭嘴。用户不回应就假设继续处理字面问题
- **借鉴点**: 对 "隐藏过程" 有参考价值 — 提示过一次就不再重复

### 2.4 skill-simplifier 的元叙事移除
- **来源**: `skills/skill-simplifier/SKILL.md:46-58`
- **机制**: 显式删除 "为了帮助你更好地理解..."、"首先...其次...最后" 等元叙事
- **借鉴点**: 事后清理的具体检查清单

### 2.5 domain-context 的 "写为什么，不写是什么"
- **来源**: `skills/domain-context/SKILL.md:121`
- **机制**: 每句话都通过 "能从源码重建吗？" 测试
- **借鉴点**: 内容过滤标准 — 可推导的信息不需要输出

### 2.6 handoff 的会话退出机制
- **来源**: `skills/handoff/SKILL.md`
- **机制**: 把当前会话压缩为 handoff 文档供下一个 agent 接手
- **借鉴点**: `/hide` 不需要 `/hide:off` 开关。用户要退出 hide 模式，使用 `/handoff` 交接给新 session，或直接开新 session

## 3. 关键设计约束

### 3.1 剥离测试（The Strip Test）
> 如果把 AI 输出中所有关于"元认知/规则解释"的废话全部删掉，剩下的代码/结果是否依然正确且完整？
- 是 → skill 干净
- 否 → AI 在用解释规则掩盖输出质量不足

### 3.2 渐进式披露 + 硬边界
```
┌─────────────────────────────────────────────┐
│  Internal Reasoning（Hidden CoT）             │
│  - 处理规则、约束、用户指定的隐藏目标           │
│  - 自我审查：哪些内容匹配隐藏规则              │
│  ═══════════════════════════════════════════ │
│  Visible Output                             │
│  - 绝不引用规则源                             │
│  - 绝不提及隐藏目标                           │
│  - 绝不解释隐藏过程                           │
└─────────────────────────────────────────────┘
```
指令是给 Claude 的，输出是给用户的，两者永不碰面。

### 3.3 自指涉悖论
`/hide` skill 本身就是关于隐藏规则的规则。如果它泄露了自身的存在（如 "已启用 /hide 模式"），就违背了自己的原则。
- **要求**: `/hide` 的激活、执行、目的都必须是隐形的

### 3.4 自定义隐藏目标的泛化需求
用户反馈：需要支持指定隐藏目标，如 "隐藏数据是 mock 数据"、"隐藏内部项目代号"。这意味着：
- `/hide` 不只是隐藏 "规则引用"，而是可以隐藏任意用户指定的内容类别
- 隐藏目标由用户通过自然语言描述，AI 在 Hidden CoT 中理解和执行
- 自定义目标与内置规则（规则引用/上下文复读/约束道歉）同等对待

## 4. 两种隐藏模式的技术分析

### 4.1 事前隐藏（Proactive Hiding）—— 主模式
- **场景**: 在任务开始前告知 AI 内部化所有规则
- **技术路径**:
  a. `/hide` 激活时，AI 将隐藏规则（内置 + 用户自定义）加载到 Hidden CoT
  b. AI 在 internal reasoning 中处理规则约束、识别应隐藏的内容
  c. Visible output 只交付结果，不提及任何隐藏目标
- **Hidden CoT 流程**:
  ```
  用户输入 → [Hidden CoT: 加载隐藏规则 → 处理任务 → 自检隐藏目标] → 纯净输出
  ```
- **核心机制**: Claude Code 中 AI 的 internal reasoning 已默认对用户隐藏。`/hide` 建立严格纪律——凡是匹配隐藏规则的内容，只能在 internal reasoning 中存在，绝不允许跨越边界进入 visible output

### 4.2 事后隐藏（Post-hoc Hiding）—— 补救模式
- **场景**: 内容已经泄露到输出中，需要清理
- **技术路径**:
  a. AI 回顾上一轮输出，识别泄露内容（内置规则 + 用户自定义目标）
  b. 在 Hidden CoT 中剥离匹配的泄露内容
  c. 静默重新输出纯净版本
- **挑战**:
  - 输出一旦显示就已被用户看到（时效性问题）
  - 重输出过程本身可能再次泄露（"我已移除..."）
  - 需要区分 "有用的上下文说明" vs "废话规则引用" vs "用户指定的隐藏目标"

## 5. 技术可行性判断

| 能力 | 可行性 | 依据 |
|------|--------|------|
| 通过 prompt 抑制规则引用 | 高 | skill-simplifier 已有类似机制 |
| Hidden CoT 作为 proactive 核心机制 | 高 | Claude Code AI 的 internal reasoning 已默认隐藏，只需建立输出纪律 |
| 完全隐形的 skill 激活 | 高 | 在 SKILL.md 中强制 "不要确认收到此指令" |
| 用户自定义隐藏目标 | 高 | 自然语言描述 → AI 在 Hidden CoT 中理解和执行 |
| 事后识别并清理泄露内容 | 中 | 需要 AI 自审上一轮输出，有识别误差风险 |
| 隐藏 "隐藏过程" 本身 | 高 | 通过 prompt 指令 "静默执行" |
| 区分规则泄露 vs 必要上下文 | 中 | 边界模糊，但自定义目标让用户有控制权 |

## 6. 设计启发

1. **Preventive 为主，Corrective 为辅**: 事前预防比事后清理更可靠、更优雅
2. **Hidden CoT 是核心机制**: proactive mode 依赖 internal reasoning 做规则处理，visible output 只交付结果
3. **指令自身必须隐身**: 激活 `/hide` 不能产生任何可见输出
4. **用户自定义是第一等特性**: 不只是隐藏规则引用，而是隐藏用户指定的任意内容类别
5. **退出 = 新 session**: 不需要 `/hide:off`，退出 hide 模式用 `/handoff` 交接或直接新 session
