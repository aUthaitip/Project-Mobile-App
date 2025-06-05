import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:teeyai_app/models/category_model.dart';
import 'package:logging/logging.dart';

class addCategoryScreen extends StatefulWidget {
  const addCategoryScreen({Key? key}) : super(key: key);

  @override
  State<addCategoryScreen> createState() => _addCategoryScreenState();
}

class _addCategoryScreenState extends State<addCategoryScreen> {
  final _log = Logger('AddCategoryScreen');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameTHController = TextEditingController();
  final TextEditingController nameEngController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  Future<void> _saveCategoryToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('Categories').add({
        'name_th': nameTHController.text,
        'name_eng': nameEngController.text,
        'imageUrl': imageUrlController.text,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกหมวดหมู่เรียบร้อย')));

      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มหมวดหมู่',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 232, 77, 74),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'เพิ่มหมวดหมู่ใหม่',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 232, 77, 74),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameTHController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อภาษาไทย',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อหมวดหมู่';
                  }
                  return null;
                },
              ),
                const SizedBox(height: 16),
              TextFormField(
                controller: nameTHController,
                decoration: const InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please enter category name';
                  }
                  return null;
                },
              ),
                const SizedBox(height: 16),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'imageUrl',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่ URL ของภาพ';
                  }
                  return null;
                },
              ),
                    const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveCategoryToFirestore();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 232, 77, 74),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
