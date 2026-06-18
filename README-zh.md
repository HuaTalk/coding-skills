# Skill

[English](./README.md)

Claude Code plugin 通用框架：把团队约定的 commands、skills 与 MCP 配置封装成可在多个仓库间复用的一套上下文。

遵循 **"Rules Are for You"** 哲学——规则为 AI 决策服务，不在输出中现身。好的 skill 像资深工程师直接干活，不边读文档边念。

本仓库即 Claude Code plugin，也即 marketplace。

## 30 秒上手

在目标项目根目录启动 Claude Code：

```
/plugin marketplace add https://github.com/HuaTalk/skills.git
/plugin install skill@skill
```

重启 Claude Code 后，所有 commands / skills / `.mcp.json` 在该项目可用。

升级：`/plugin update skill@skill` + 重启。
临时禁用：`/plugin disable skill@skill`。

## 目录结构

```
.
├── .claude-plugin/
│   ├── plugin.json         # plugin 清单
│   └── marketplace.json    # marketplace 清单
├── commands/               # slash command（plugin 根目录自动发现）
├── skills/                 # skill（plugin 根目录自动发现）
│   ├── best-effort-delivery/   # 模糊任务尽最大努力交付
│   ├── brainstorming/          # 动手前需求澄清（来自 obra/superpowers）
│   ├── domain-context/         # 领域知识沉淀协议
│   ├── explore-legacy/         # 历史代码探路
│   ├── handoff/                # 会话交接
│   ├── light-explore/          # 轻量探讨
│   ├── openspec-explore/       # OpenSpec 自由探索
│   ├── skill-simplifier/       # Skill 精简瘦身
│   └── unknown-unknowns/       # 盲点提醒
├── .mcp.json               # MCP 服务器（intellij-index）
├── .claude/
│   └── settings.json       # 本仓库自用 permissions（不随 plugin 分发）
├── CLAUDE.md               # 项目指令（英文版）
├── CLAUDE-zh.md            # 项目指令（中文版）
├── README.md               # 本文件（英文版）
├── README-zh.md            # 中文版 README
├── ROADMAP.md
└── blog-rules-are-for-you.md  # 设计哲学
```

> Claude Code plugin 规范要求 `commands/` `skills/` 在仓库根目录，不能嵌在 `.claude/` 下。`.claude/settings.json` 是本仓库自用配置，不随 `/plugin install` 分发。

## 国际化（i18n）

所有 skill 均支持英文（默认）与中文（`-zh` 变体）。切换方式见 [CLAUDE-zh.md](./CLAUDE-zh.md#国际化i18n)。

## 配置指南

### 1. 通过 plugin 安装（推荐）

安装后 Claude Code 自动加载：
- `commands/` 下所有 `.md` → 注册为 slash command
- `skills/<name>/SKILL.md` → 注册为按需触发的 skill
- `.mcp.json` → 合并到当前项目的 MCP 服务器列表

### 2. MCP 服务器

`.mcp.json` 预置 `intellij-index`，用于 IntelliJ IDEA 的代码智能。

准备工作：在 IntelliJ IDEA 安装 IDE Index MCP Server 插件，IDE 启动后监听 `127.0.0.1:29170`。

验证：`lsof -i :29170` 能看到 `idea` 进程在监听。

### 3. 兜底：软链方式

```bash
ln -s ~/path/to/skill/commands  /path/to/your-project/.claude/commands
ln -s ~/path/to/skill/skills    /path/to/your-project/.claude/skills
ln -s ~/path/to/skill/.mcp.json /path/to/your-project/.mcp.json
```

### 4. 个人 settings

`.claude/settings.json` 是本仓库自用的 permissions 默认（不随 plugin 分发）。个人偏好写到目标项目的 `.claude/settings.local.json`（gitignored）。

### 5. Beta 技能

`best-effort-delivery` 为 beta 状态，需显式启用：

```json
// 目标项目 .claude/settings.local.json
{ "enable_beta_skills": true }
```

## Skill 选用指南

| 场景 | skill |
|------|-------|
| 新功能 / 大改造 / 影响线上 | `brainstorming` |
| 1-2 个待澄清的小改动 | `light-explore` |
| 不熟的老代码 / 根因排查 | `explore-legacy` |
| 提问已隐含解法、但可能错位 | `unknown-unknowns` |
| 模糊任务、用户要求自主推进 | `best-effort-delivery` |
| 领域规则沉淀 | `domain-context` |
| 单点 bug / 配置 / < 30 行明确改动 | 跳过 skill，直接做 |

## 维护

新增 skill / command 时：
1. 在 `skills/<name>/SKILL.md` 或 `commands/<name>.md` 写定义
2. 通知使用方运行 `/plugin update skill@skill` + 重启

后续改进路线见 [ROADMAP.md](./ROADMAP.md)。
