import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/widgets/menu_screen_widget.dart';
import 'package:teeyai_app/screens/customer/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:teeyai_app/providers/cart_provider.dart';
import 'admin/login.dart';
import 'package:teeyai_app/models/category_model.dart';
import 'package:logging/logging.dart';

final _log = Logger('HomeScreen');

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<List<CategoryModel>> _fetchCategories() {
    return FirebaseFirestore.instance
        .collection('Categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromDocument(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F3),
      appBar: AppBar(
        title: const Text(
          'Teeyai',
          style: TextStyle(
            fontFamily: 'NotoSansThai',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE34C4C),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<CategoryModel>>(
          stream: _fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              _log.warning('Error: ${snapshot.error}');
              _log.severe('Firestore Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuScreen(
                            category_id: category.id ?? '',
                            category_name_th: category.name_th ?? '',
                            category_name_eng: category.name_eng ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                     
                       
                      decoration: BoxDecoration(


                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: category.imageUrl != null &&
                                    category.imageUrl!.isNotEmpty
                                ? Image.network(
                                    category.imageUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image,
                                            size: 40),
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            category.name_th ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}