package shopping;

import java.util.HashMap;
import java.util.Map;

public class Cart {
    private Map<String, Product> cart;

    public Cart() { this.cart = new HashMap<>(); }
    public Map<String, Product> getCart() { return cart; }

    public boolean add(Product product) {
        if (this.cart == null) this.cart = new HashMap<>();
        if (this.cart.containsKey(product.getId())) {
            int currentQuantity = this.cart.get(product.getId()).getQuantity();
            product.setQuantity(currentQuantity + product.getQuantity());
        }
        this.cart.put(product.getId(), product);
        return true;
    }

    public boolean edit(String id, int quantity) {
        if (this.cart != null && this.cart.containsKey(id)) {
            this.cart.get(id).setQuantity(quantity);
            return true;
        }
        return false;
    }

    public boolean remove(String id) {
        if (this.cart != null && this.cart.containsKey(id)) {
            this.cart.remove(id);
            return true;
        }
        return false;
    }

    public double getTotal() {
        double total = 0;
        if (this.cart != null) {
            for (Product p : this.cart.values()) {
                total += p.getPrice() * p.getQuantity();
            }
        }
        return total;
    }
}