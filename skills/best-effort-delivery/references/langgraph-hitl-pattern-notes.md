# LangGraph HITL Mapping for Best-Effort Delivery

LangGraph has no official "pending queue" term. Batch review is an `__interrupt__` array: parallel nodes call `interrupt()`, then one `Command(resume={id: value})` resumes them together. At the agent layer, `HumanInTheLoopMiddleware` uses `Command(resume={"decisions": [...]})` to resolve pending tool calls in order with approve, edit, or reject decisions.

Idempotency applies at the node level. Resuming reruns the node from its start, so side effects before `interrupt()` repeat. Use upserts, move side effects after the interrupt, or isolate them in another node. In this skill, a resumed pass consumes only the exported HTML JSON delta; it must not rerun or overwrite high-confidence work already completed.

Deep Agents uses the same shape: `interrupt_on`, a checkpointer, and a `decisions` array, without an offline HTML form.

Useful terms: `resume payload` for the JSON export, `idempotent replay` for resumed-pass constraints, and `batch resume` for resolving several questions in one JSON payload.
