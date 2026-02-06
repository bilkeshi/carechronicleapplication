import 'package:flutter/material.dart';

import 'cart_screen.dart';

class PharmacyScreen extends StatefulWidget {
  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final List<WoundCareProduct> _products = [
    WoundCareProduct(
      name: 'Hydrocolloid Dressing',
      description: 'For moderate to heavily exuding wounds.',
      price: 15.99,
      imageUrl: 'images/hydro.jpg',
    ),
    WoundCareProduct(
      name: 'Silver Alginate Dressing',
      description: 'For infected or high-risk wounds.',
      price: 22.50,
      imageUrl: 'images/silver.jpg',
    ),
    WoundCareProduct(
      name: 'Hydrogel Wound Gel',
      description: 'Helps maintain a moist wound environment.',
      price: 10.99,
      imageUrl: 'images/hydrogel.jpg',
    ),
    WoundCareProduct(
      name: 'Antiseptic Ointment',
      description: 'For cleaning and disinfecting wounds.',
      price: 8.99,
      imageUrl: 'images/antisepticoil.jpg',
    ),
    WoundCareProduct(
      name: 'Wound Healing Cream',
      description: 'Promotes tissue regeneration and healing.',
      price: 12.49,
      imageUrl: 'images/healingcream.jpg',
    ),
  ];

  int _cartCount = 0;
  Map<String, int> _cartItems = {};

  void _addToCart(WoundCareProduct product) {
    int _selectedQuantity = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Select Quantity for ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Quantity:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_selectedQuantity > 1) {
                            _selectedQuantity--;
                          }
                        });
                      },
                    ),
                    Text('$_selectedQuantity',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_selectedQuantity < 10) {
                            _selectedQuantity++;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _cartCount += _selectedQuantity;
                    _cartItems[product.name] =
                        (_cartItems[product.name] ?? 0) + _selectedQuantity;
                  });
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Added to Cart'),
                      content: Text(
                          '$_selectedQuantity x ${product.name} has been added to your cart.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Add to Cart'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Care Pharmacy'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
        actions: [
          // Cart icon with count
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 30,
                ),
                if (_cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: Text(
                        '$_cartCount',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: _cartItems,
                    products: _products,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chronic Wound Care Products',
              style: TextStyle(
                fontSize: 20.5,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () => _addToCart(product),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WoundCareProduct {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  WoundCareProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}