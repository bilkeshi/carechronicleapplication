import 'package:flutter/material.dart';

import 'checkout_screen.dart';
import 'pharmancy_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cartItems;
  final List<WoundCareProduct> products;

  CartScreen({required this.cartItems, required this.products});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Calculate total price of items in the cart
  double _calculateTotal() {
    double total = 0.0;
    widget.cartItems.forEach((name, quantity) {
      final product = widget.products.firstWhere((p) => p.name == name);
      total += product.price * quantity;
    });
    return total;
  }

  // Remove item from the cart
  void _removeFromCart(String productName) {
    setState(() {
      widget.cartItems.remove(productName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        String productName =
                            widget.cartItems.keys.elementAt(index);
                        int quantity = widget.cartItems[productName]!;
                        final product = widget.products
                            .firstWhere((p) => p.name == productName);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                product.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[700],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity: $quantity',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Price: \$${(product.price * quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.deepPurple[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _removeFromCart(productName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('$productName removed from cart'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              cartItems: widget.cartItems,
                              products: widget.products,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7165D6),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
