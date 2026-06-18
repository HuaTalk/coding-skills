package com.example.order;

import java.util.List;
import java.util.ArrayList;

/**
 * Order service for processing customer orders.
 * Handles creation, validation, and fulfillment.
 */
public class OrderService {

    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;

    public OrderService(OrderRepository orderRepository, InventoryService inventoryService) {
        this.orderRepository = orderRepository;
        this.inventoryService = inventoryService;
    }

    /**
     * Create a new order for the given customer.
     *
     * @param customerId the customer ID
     * @param items the order items
     * @return the created order
     */
    public Order createOrder(String customerId, List<OrderItem> items) {
        if (customerId == null || customerId.isBlank()) {
            throw new IllegalArgumentException("Customer ID is required");
        }

        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("Order must have at least one item");
        }

        for (OrderItem item : items) {
            boolean available = inventoryService.checkAvailability(item.productId(), item.quantity());
            if (!available) {
                throw new InsufficientInventoryException(
                    "Product %s not available in requested quantity".formatted(item.productId())
            );
            }
        }

        Order order = new Order(customerId, items);
        order.setStatus(OrderStatus.CREATED);

        return orderRepository.save(order);
    }

    /**
     * Calculate the total price for an order.
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
     * Validates the order exists and is in a cancellable state.
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
