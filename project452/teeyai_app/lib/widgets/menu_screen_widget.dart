import 'package:flutter/material.dart';
import 'package:teeyai_app/models/menu_item.dart';
import 'package:teeyai_app/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:teeyai_app/screens/customer/cart_screen.dart';
import 'package:logging/logging.dart';

final _log = Logger('MenuScreen');

class MenuScreen extends StatelessWidget {
  final String category_id;
  final String? category_name_th;
  final String? category_name_eng;

  const MenuScreen({
    super.key,
    required this.category_id,
    required this.category_name_th,
    required this.category_name_eng,
  });

  Stream<List<MenuItem>> _fetchMenu(String categoryId) {
    return FirebaseFirestore.instance
        .collection('Menus')
        .where('category_id', isEqualTo: categoryId)
        .where('status', isEqualTo: 1)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromDocument(doc.id, doc.data()))
            .toList());
  }

  void _showAddToCartDialog(BuildContext context, MenuItem item, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddToCartDialog(item: item, cart: cart);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category_name_th ?? 'Menu',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 232, 77, 74),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    cart.itemCount.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItem>>(
        stream: _fetchMenu(category_id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _log.warning('Error: ${snapshot.error}');
            _log.severe('Firestore Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final menus = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final item = menus[index];
              return Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 3,
                color: const Color(0xFFFFF7F7),
                child: InkWell(
                  onTap: () => _showAddToCartDialog(context, item, cart),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          item.imageUrl,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price} ฿',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: () => _showAddToCartDialog(context, item, cart),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE34C4C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddToCartDialog extends StatefulWidget {
  final MenuItem item;
  final CartProvider cart;

  const _AddToCartDialog({required this.item, required this.cart});

  @override
  __AddToCartDialogState createState() => __AddToCartDialogState();
}

class __AddToCartDialogState extends State<_AddToCartDialog> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.item.price} ฿',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(widget.item.imageUrl, height: 150, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              'Select Quantity',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton(
          onPressed: () {
            if (quantity > 0) {
              widget.cart.addToCart(widget.item, quantity);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.item.name} added to cart')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid quantity')),
              );
            }
          },
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}
