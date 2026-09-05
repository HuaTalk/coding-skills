---
name: context-router
description: Layered context routing for agent-facing project design docs — root AGENTS.md directive → design/AGENTS.md router table (pointers + one-line summaries) → flat per-feature docs. Use when organizing design docs/ADRs/contracts for coding agents (Codex/Claude/Kimi), or when the user mentions 上下文指针、路由文件、按需加载文档、设计文档整理.
metadata:
  author: HuaTalk
  version: "1.0.0"
---

# Context Router：agent 设计文档的分层路由

为 coding agent 组织项目设计知识时，使用三层结构：

```
根 AGENTS.md        # 每次会话必加载：强指令 + 一句话功能概览
  └─ design/AGENTS.md   # 路由表：指针 + 一句话摘要
       └─ 各具体设计文档   # 按功能命名，扁平存放
```

## 原则

1. 唯一可靠的入口是 always-loaded 指令文件（AGENTS.md / CLAUDE.md）。agent 不会自发发现某个文件夹里的路由文件——路由指令必须放进根指令文件。
2. 路由表只有两列：文档 + 一句话摘要。不需要"何时读取"列——agent 会按摘要自行判断是否加载。
3. 明确禁止预读：路由文件开头写"先读本表，只加载命中的文档，不要预读全部"。
4. 扁平结构：路由目录下不要子目录，用功能前缀命名文件。
5. 每个知识目录一份 AGENTS.md：嵌套 AGENTS.md 会被 agent 在进入该目录时自动加载（目录作用域兜底），但不替代根路由。
7. 已发布的站点页面不物理迁移（避免破站），由路由文件收录指针即可。
8. 路由表保持小：每条一行；超过 ~100 行就该拆分。

## 落地清单

- 根 AGENTS.md 加路由块：强指令（"改动 X 前，先读 design/AGENTS.md，按摘要匹配加载，不要预读全部"）+ 一行功能概览。
- design/AGENTS.md：使用规则 + 按功能分组的表格（文档 | 摘要）。
- 迁移用 `git mv` 保留历史；更新所有入链（文档互链、mkdocs nav、其他引用）。
- 把 design/ 纳入仓库的链接检查脚本扫描范围。
- 验证：给一个真实任务，观察 agent 是否先读路由、只读命中文档；不命中就调摘要措辞，而不是加内容。
