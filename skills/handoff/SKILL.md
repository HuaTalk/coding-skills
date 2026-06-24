---
name: handoff
description: 把当前会话压缩为 handoff 文档供下一个 agent 接手。需要交接上下文、切换 session 时使用。
argument-hint: "What to compact & what will the next session be used for?"
metadata:
  author: HuaTalk
  version: "1.0.0"
  category: methodology
  status: stable
---

将会话摘要写成 handoff 文档，让新 agent 能接手继续工作。保存到用户操作系统的临时目录，不写入当前工作区。

文档中需包含"suggested skills"章节，建议下一个 agent 应调用的 skill。

不要重复其他产物（PRD、计划、ADR、issue、commit、diff）中已有的内容，用路径或 URL 引用它们。

如果用户传了参数，将其视为"要压缩什么 + 下一个会话关注什么"的说明，据此定制文档。
