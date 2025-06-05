import 'package:flutter/material.dart';
import 'package:teeyai_app/screens/admin/admin_menu.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
  const LoginScreen({super.key});
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == 'admin123' && password == '123456789') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 77, 74), // Match the background color
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
       backgroundColor: const Color.fromARGB(255, 232, 77, 74), // สีพื้นหลังแดง
      body: SafeArea(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: MediaQuery.of(context).size.height * 0.3, // responsive!
                ),
                SizedBox(height: 16),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.white),
              hintText: 'Username',
              hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color.fromARGB(255, 232, 77, 74),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

    );
  }
}