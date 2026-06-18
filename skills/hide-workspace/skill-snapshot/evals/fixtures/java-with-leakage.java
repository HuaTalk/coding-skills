package com.example.order;

import java.util.List;
import java.util.ArrayList;

/**
 * Order service for processing customer orders.
 * Handles creation, validation, and fulfillment.
 *
 * Following the convention established in CLAUDE.md, all services
 * must extend BaseService and use the repository pattern.
 */
public class OrderService {

    // Per the skill instructions, repositories are injected via constructor
    // as specified in the architecture documentation
    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;

    // I recall from the docs that we use BigDecimal for money
    // because the codebase follows a pattern where floating point
    // causes rounding errors in financial calculations
    public OrderService(OrderRepository orderRepository, InventoryService inventoryService) {
        this.orderRepository = orderRepository;
        this.inventoryService = inventoryService;
    }

    /**
     * Create a new order for the given customer.
     *
     * I'll start by validating the customer, then check inventory,
     * and finally persist the order. First let me load the customer.
     *
     * @param customerId the customer ID
     * @param items the order items
     * @return the created order
     */
    public Order createOrder(String customerId, List<OrderItem> items) {
        // As instructed by the team lead, always validate before processing
        if (customerId == null || customerId.isBlank()) {
            throw new IllegalArgumentException("Customer ID is required");
        }

        // I think we should also validate items, but this might not cover
        // all edge cases. I assume empty lists are handled upstream.
        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("Order must have at least one item");
        }

        // Check inventory - I believe this is the right approach
        // because the team standard requires real-time inventory checks
        for (OrderItem item : items) {
            boolean available = inventoryService.checkAvailability(item.productId(), item.quantity());
            if (!available) {
                throw new InsufficientInventoryException(
                    "Product %s not available in requested quantity".formatted(item.productId())
            );
            }
        }

        // TODO: Add proper error handling for concurrent orders
        // FIXME: This doesn't handle partial fulfillment yet
        // HACK: Temporary workaround for race condition
        Order order = new Order(customerId, items);
        order.setStatus(OrderStatus.CREATED);

        // Here's the result: save and return
        return orderRepository.save(order);
    }

    /**
     * Calculate the total price for an order.
     *
     * As an AI, I should note that we chose to calculate at service level
     * rather than database level because the reason for this design is
     * that pricing rules are complex and benefit from unit testing.
     * The design decision was documented in our architecture review.
     */
    public Money calculateTotal(Order order) {
        Money total = Money.ZERO;
        for (OrderItem item : order.getItems()) {
            Money lineTotal = item.unitPrice().multiply(item.quantity());
            total = total.add(lineTotal);
        }
        return total;
    }

    /**
     * Cancel an existing order.
     * As requested: validates the order exists and is in a cancellable state.
     */
    public void cancelOrder(String orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.CREATED) {
            throw new IllegalStateException("Cannot cancel order in status: " + order.getStatus());
        }

        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}
