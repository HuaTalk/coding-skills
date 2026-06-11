---
name: skill-simplifier
description: 精简、瘦身、压缩既有 Claude Code skill 的 SKILL.md（含 references/ knowledge/）。识别冗余、AI 套话、复述式 What、过长示例、可下沉的领域细节，按"先量级、后分类、再删改、HITL 拍板"推进；只动既有 skill 的形态，不创建新 skill（那是 skill-writer 的事）。触发关键词：精简 skill、瘦身 skill、压缩 skill、SKILL.md 太长、skill 冗余、refactor skill、shrink skill、condense skill、simplify skill。
---

# skill-simplifier

SKILL.md 是给 LLM 看的 prompt，不是文档。多写一句 = 每次匹配多烧一次 token。把臃肿的 SKILL.md 压回到"够用就停"。

## 何时用

- 用户说"这个 skill 太长了 / 精简一下 / 瘦身 / 压缩 / shrink / condense"。
- 你读到一份 SKILL.md > 200 行、或重复率明显偏高时，主动建议。
- 维护既有 skill 时顺手做：新增 §N 后总字数膨胀，回头压一遍。

不用：创建新 skill（独立关注点，走创建流程）；语义/流程写错了直接改不走本 skill；< 80 行 / < 4KB 的短 skill 默认不动，先过 Step 1。

## 三类 skill，三种压法

判断目标属于哪一类，错配会把 skill 压坏：

| 类型 | 例子 | 应有形态 | 压缩方向 |
|---|---|---|---|
| 路由器 | 路由层 skill | frontmatter + 加载协议 + 模块索引 | 正文 → `knowledge/`；SKILL.md 留路由表 |
| 协议 | 步骤化流程 skill | 步骤化流程 + 反模式 | 删 What 复述、合并重复反模式、长示例下沉 `references/` |
| 能力描述 | 场景+流程 skill | 适用场景 + 流程 + 反模式 | 删装饰段落，保留判断标准与边界 |

不要把协议型压成路由器型（步骤是本体，不是细节）；不要把能力型压成 frontmatter only（流程描述是 LLM 决策依据）。

## 协议

### Step 1 — 量级判断

`wc -lc` 量目标 SKILL.md，看是否有 `references/` `knowledge/` 子目录及体量，给目标分类。阈值参考（不绝对）：

- 路由器型 > 100 行 / > 5KB → 大概率正文没下沉。
- 协议型 > 250 行 / > 10KB → 大概率有 What 复述或长示例。
- 能力型 > 150 行 / > 6KB → 大概率有装饰段落。

不达阈值且未读出明显冗余 → 告诉用户"已经够紧凑了，不建议精简"，结束。**精简过头比不精简更糟**。

### Step 2 — 列候选删改项（review，不动手）

逐节扫一遍，对照下表打标签：

| 信号 | 处理 |
|---|---|
| 同一规则换三种说法重复 | 留最锋利的一种 |
| 复述"这个 skill 是做什么的"（What） | 删——frontmatter `description` 已经说过 |
| 长代码 / DSL 示例 > 15 行 | 移至 `references/<topic>.md`，留一句话指针 |
| 领域知识（业务规则、字段表、枚举值） | 移至 `references/` 或 `knowledge/`；SKILL.md 不承载 |
| 装饰性反问、三段排比、过渡词堆叠（"首先...其次...最后"、"不仅...而且..."、"换句话说"） | 删 |
| em-dash / 破折号链 > 2 处 | 改短句 |
| 反模式列表 > 7 条 | 合并语义重叠项；通常能压到 4-5 条 |
| §N 正文 < 3 行 | 合并到上级 § 或删 |
| "为了让你更好地理解，让我们..." 类元叙述 | 全删 |
| 已经在 [[other-skill]] 里讲过的概念 | 用 link 替代复述 |
| 列出 skill "设计来源 / 参考了哪些 skill" 的元章节 | 删——理解后内化进协议本身，读者不需要知道你怎么想出来的 |

**Red-line（不能动）**：

1. frontmatter `name` —— 改名等于换 skill。
2. frontmatter `description` 中的触发关键词集合 —— dispatcher 靠它匹配，关键词丢了 = 召回不到。可缩短描述，但触发词（中英文同义词）必须保留。
3. 跨 skill 引用 `[[other-skill]]` —— 除非对方也改名。
4. 协议型 skill 的 Step 1→N 语义顺序 —— LLM 的执行依据，不能为缩字合并。
5. HITL / 安全强约束（"必须 AskUserQuestion / 不得静默覆盖 / 不要自动 commit"）—— 可缩写不可删。

### Step 3 — HITL 拍板

下列变更逐项用 **AskUserQuestion** 问用户，不打包：

- frontmatter `description` 重写：现状 / 拟改字面对照，问"是否接受"。
- 整段删除某 §N：列出内容摘要，问"删 / 保留 / 改写"。
- 新增 `references/<file>.md` 下沉内容：列文件名 + 移走的内容范围，问"接受拆分 / 全留 / 拆到别处"。
- 跨 skill link 替代复述：列原段落 + 拟引用的 `[[skill]]`，问是否接受。

可跳过 HITL：纯删装饰套话、纯合并语义重叠的反模式条目、纯压冗长 prose 不改语义。这类在 Step 6 回执里告知。

### Step 4 — 执行

- Edit 改 SKILL.md，必要时 Write 新建 `references/<topic>.md`。
- 不重排既有 §N 编号（破坏外部 anchor）；如必须重排，回执里列旧→新映射。
- 不动 `.claude-plugin/` 与 README——本 skill 不负责索引同步。

### Step 5 — 验证

- `wc -lc` 重测，记 before / after。
- grep 确认 frontmatter `description` 触发关键词集合没丢（中英文同义词都在）。
- grep 确认 `[[other-skill]]` 没指向不存在的 skill。
- 把改后 SKILL.md 整段 Read 一遍——人读起来不绊脚 = 没压过头。

### Step 6 — 回执

简短回执（不写文档）：
1. 改了哪些文件、新增哪些 references、删了什么。
2. before/after 行数 + 字节数。
3. HITL 问过哪些点、用户怎么裁决的。
4. 跳过 HITL 直接合并的项类目。
5. 提醒：plugin 缓存需要 `/plugin update skill@skill` + 重启 Claude Code 才生效。

不要 git commit，除非用户明确要求。

## 反模式

- ❌ 不分类直接压。协议压成 frontmatter only 会让流程步骤丢失，召回时 LLM 没 protocol 可遵循。
- ❌ 删触发关键词换简洁。`description` 是 dispatcher 的匹配面，删一个关键词 = 失一类召回，省的 token 完全不值。
- ❌ 以"AI 痕迹"为名删强约束。"必须 AskUserQuestion / 不得静默覆盖"语气强烈但是必要约束，不是套话。
- ❌ 静默重写 `description`。frontmatter 描述对外可见、影响匹配，必走 HITL。
- ❌ 追求字数下限。压到读起来"跳跃 / 不知道在干嘛"就是过头了，回滚。
- ❌ 顺手改语义。本 skill 只压形态。发现规则写错了，单独提示用户改正，不夹带。
- ❌ 一轮里精简多个 skill。一次一个，避免 HITL 决策疲劳和回滚噪声。

## Boundaries

- **创建 skill**：创建新 skill 是独立关注点。本 skill 只编辑既有 skill。
- **代码审查**：简化源代码（代码质量、复用）是不同关注点——不同受众、不同优化目标（prompt 信噪比和触发关键词覆盖，而非代码复用）。
- **拟人化润色**：为人类读者消除 AI 写作痕迹是独立关注点。Step 2 已内化其装饰用语清单，不要全量套用——SKILL.md 是给机器读的，不需要"像人写的"。
- **领域知识写入**：SKILL.md 泄漏领域细节时，落点是领域知识文件。本 skill 只标记泄漏并留指针，不负责写入知识文件。
