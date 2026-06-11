# CLAUDE.md

Claude Code plugin 通用框架仓库。提供 commands、skills、MCP 配置的可复用集合。

## 仓库定位

这不是业务代码仓库，是 Claude Code plugin 模板仓库。仓库即 plugin，也即 marketplace（见 `.claude-plugin/plugin.json` 与 `.claude-plugin/marketplace.json`）。

工作产物只有三类：
- `.claude-plugin/{plugin,marketplace}.json` — plugin/marketplace 清单
- `commands/*.md` — slash command
- `skills/<name>/SKILL.md` — skill

没有源代码、没有构建、没有测试。

## skill 三种来源

1. **团队自研**：`domain-context`、`handoff`、`openspec-explore`、`best-effort-delivery`、`explore-legacy`、`light-explore`、`unknown-unknowns`、`skill-simplifier`。在本仓库内直接修改。
2. **上游管理**：`brainstorming`（来自 [obra/superpowers](https://github.com/obra/superpowers)）。通过 upstream 整体替换，不直接修改。
3. **消费者自行安装**：lark-*、meegle、planning-with-files 等供应商/社区 skill 由用户在自己的 Claude Code 环境中安装，本仓库不携带。

## 国际化（i18n）

所有 skill 均支持英文（默认）和中文。命名约定：

- `SKILL.md` — 英文版（dispatcher 默认加载）
- `SKILL-zh.md` — 中文版

切换为中文版：symlink 或复制 zh 变体：

```bash
cd skills/<skill-name>
cp SKILL-zh.md SKILL.md
```

同样模式适用于 `CLAUDE.md`（`CLAUDE-zh.md`）、`README.md`（`README-zh.md`）和 `commands/*.md`（`*-zh.md`）。

## 领域知识沉淀

`domain-context` skill 提供通用的领域知识管理协议：把会话中沉淀的规则按"重架构、轻细节"原则固化到结构化知识文件中。消费者按需建立自己的 `knowledge/` 目录结构。

## 业务仓库使用方式

通过 Claude Code plugin 安装：

```bash
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

兜底软链方式：

```bash
ln -s ~/path/to/skill/commands  /path/to/your-project/.claude/commands
ln -s ~/path/to/skill/skills    /path/to/your-project/.claude/skills
ln -s ~/path/to/skill/.mcp.json /path/to/your-project/.mcp.json
```

## 维护

新增 skill / command 时：
1. 在 `skills/<name>/SKILL.md` 或 `commands/<name>.md` 写定义
2. 通知使用方运行 `/plugin update skill@skill` + 重启 Claude Code

后续改进路线见 `ROADMAP.md`。
