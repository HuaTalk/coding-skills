# Design Decision: Order Cancellation Flow

## Context

The existing codebase does not support order cancellation. The original design assumed all orders would be completed once created.

## Current State

The order state machine (`OrderStateMachine.java`) supports the following transitions:
- CREATED -> PROCESSING
- PROCESSING -> SHIPPED
- SHIPPED -> DELIVERED

No cancellation path exists.

## Design Decision

Add cancellation logic in `OrderService` rather than extending the state machine.

Rationale:

1. Modifying the state machine has a large blast radius and requires changes to multiple downstream services.
2. Cancellation is a relatively independent operation that does not require the complexity of the state machine.
3. This approach has minimal invasiveness to existing code.

## Open Questions

- Should an audit log be added for cancellations?
- Partial cancellations are currently out of scope per team decision.
- Race condition handling between cancellation and shipment needs further design.

## References

- Order state machine: `OrderStateMachine.java`
- Design document: order-cancellation-design (internal wiki)
