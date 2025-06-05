import 'package:flutter/material.dart';
import 'package:teeyai_app/screens/admin/order_screen.dart';
import 'all_menu_screen.dart';
import 'category_screen.dart';
import 'all_menu_screen.dart';
class AdminMenu extends StatelessWidget {
  const AdminMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tee Yai',
          style: TextStyle(
            fontFamily: 'NatoSansThai',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 232, 77, 74),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
          
            _buildMenuItem(context, 'เมนูทั้งหมด', Icons.menu_book, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllMenuScreen()),
              );
            }),
            _buildMenuItem(context, 'หมวดหมู่', Icons.food_bank, () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
              );
              // Add functionality for ประวัติ
            }),
            _buildMenuItem(context, 'Order', Icons.history, () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 232, 77, 74).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Color.fromARGB(255, 232, 77, 74)),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}