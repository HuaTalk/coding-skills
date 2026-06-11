# LangGraph HITL → best-effort-delivery 对照（≤200 字）

**无官方 "pending queue" 命名。** 批量待审 = `__interrupt__` 数组；并行 node 各调 `interrupt()` 后，一次 `Command(resume={id→value})` 批量恢复。Agent 层用 `HumanInTheLoopMiddleware`，`Command(resume={"decisions":[…]})` 按序对应多个待审 tool call（approve/edit/reject）。

**幂等性在 node 级**：resume 时 node 从头重跑，`interrupt()` 前的副作用会重复——须 upsert / 后置副作用 / 拆独立 node。映射到本 skill：**二次推进只消化 HTML JSON 增量**；高置信已落地项不重跑、不覆写。

**Deep Agents** 同构：`interrupt_on` + checkpointer + `decisions` 数组，无离线 HTML 形态。

**可回流术语**：`resume payload`（JSON 导出）、`idempotent replay`（二次推进约束）、`batch resume`（一次 JSON 多题）。
