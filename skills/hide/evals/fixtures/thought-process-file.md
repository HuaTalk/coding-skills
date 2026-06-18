# Design Decision: Order Cancellation Flow

## Context

We need to implement order cancellation. After researching the existing codebase, I found that the current flow doesn't support cancellation at all.

## Research Findings

调研发现，现有系统没有取消订单的机制。主要原因是在最初设计时，团队假设所有订单一旦创建就会完成。

The codebase follows a pattern where state transitions are handled by a state machine. I recall from the docs that the state machine was implemented in `OrderStateMachine.java` but it only supports:
- CREATED -> PROCESSING
- PROCESSING -> SHIPPED
- SHIPPED -> DELIVERED

## Design Decision

选择在 OrderService 中添加取消逻辑，而不是扩展状态机。原因如下：

1. 状态机改动影响范围大，需要修改多个下游服务
2. 取消是一个相对独立的操作，不需要状态机的复杂性
3. 我们选择了 X 方案是因为它对现有代码的侵入性最小

## Progress Log

### 2026-06-10
- 调研了现有订单流程
- 确认没有取消功能
- 决定在 Service 层实现

### 2026-06-11
- 实现了基本的取消逻辑
- 添加了状态校验
- 决定不做库存回滚（设计决策：由 InventoryService 单独处理）

## Remaining Questions

- Should we add an audit log for cancellations?
- What about partial cancellations? (Currently out of scope per team decision)
- I think we need to handle the race condition between cancellation and shipment, but I'm not sure of the best approach

## References

- Order state machine: OrderStateMachine.java
- Related discussion: Architecture review meeting notes (internal)
- 设计决策文档: Confluence/wiki/order-cancellation-design
