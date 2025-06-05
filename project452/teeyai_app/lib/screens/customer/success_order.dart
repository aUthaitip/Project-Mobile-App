import 'package:flutter/material.dart';
import 'package:teeyai_app/screens/home_screen.dart';

class SuccessOrderScreen extends StatefulWidget {
  final String orderId;

  const SuccessOrderScreen({super.key, required this.orderId});

  @override
  State<SuccessOrderScreen> createState() => _SuccessOrderScreenState();
}

class _SuccessOrderScreenState extends State<SuccessOrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: const Text('Order Success', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE34C4C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ animation check
              Image.asset(
                'assets/Animation - 1746045503610.gif', 
                height: 350,
              ),

              const SizedBox(height: 24),
              const Text(
                'ส่งออเดอร์เรียบร้อย\nโปรดรอสักครู่',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'หมายเลขออเดอร์: ${widget.orderId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                'กำลังกลับไปหน้าเมนู...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}