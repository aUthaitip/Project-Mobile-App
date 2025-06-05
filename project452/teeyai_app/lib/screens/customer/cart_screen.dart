import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import '/models/menu_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/order_model.dart';
import 'success_order.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items;
    final menuItems = cart.menuItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE34C4C),
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty 😢',                   
              style: TextStyle(fontSize: 16)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (_, index) {
                      final id = cartItems.keys.elementAt(index);
                      final qty = cartItems[id]!;
                      final item = menuItems[id]!;

                      return Padding(
                        padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    '฿${item.price.toStringAsFixed(2)} x $qty',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _roundIcon(
                                  icon: Icons.remove,
                                  onPressed: () => cart.decreaseQuantity(id),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                _roundIcon(
                                  icon: Icons.add,
                                  onPressed: () => cart.increaseQuantity(id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '฿${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE34C4C),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE34C4C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final orderData = {
                          'timestamp': FieldValue.serverTimestamp(),
                          'items': cart.items,
                          'totalPrice': cart.totalPrice,
                          'tableNo': '1',
                          'status': 'pending',
                        };

                        final order = await FirebaseFirestore.instance
                            .collection('Orders')
                            .add(orderData);

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Order Placed"),
                            content: const Text("Your order has been placed!"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  cart.clearCart();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SuccessOrderScreen(orderId: order.id),
                                    ),
                                  );
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// ปุ่มกลม ±
  Widget _roundIcon({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}