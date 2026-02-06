import 'package:flutter/material.dart';

import 'pharmancy_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, int> cartItems;
  final List<WoundCareProduct> products;

  CheckoutScreen({required this.cartItems, required this.products});

  double _calculateTotal() {
    double total = 0.0;
    cartItems.forEach((name, quantity) {
      final product = products.firstWhere((p) => p.name == name);
      total += product.price * quantity;
    });
    return total;
  }

  void _completeCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order Confirmed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for your purchase!'),
            SizedBox(height: 10),
            Text(
                'Your order will be packaged and shipped on the next working day.'),
            SizedBox(height: 10),
            Text(
              'Order Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            ...cartItems.entries.map((entry) {
              final product = products.firstWhere((p) => p.name == entry.key);
              return Text(
                '${entry.value} x ${product.name} - \$${(product.price * entry.value).toStringAsFixed(2)}',
              );
            }).toList(),
            SizedBox(height: 10),
            Text(
              'Total: \$${_calculateTotal().toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
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
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        String productName = cartItems.keys.elementAt(index);
                        int quantity = cartItems[productName]!;
                        final product =
                            products.firstWhere((p) => p.name == productName);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            leading: Image.asset(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[700],
                              ),
                            ),
                            subtitle: Text(
                              'Quantity: $quantity\nPrice: \$${(product.price * quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Text(
                    'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  Divider(),
                  Text(
                    'Your order will be packaged and sent on the next working day.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _completeCheckout(context),
                    child: Text(
                      'Complete Checkout',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7165D6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 48),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
