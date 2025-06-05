import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/category_model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/category_model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/category_model.dart';

class CategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final void Function(String?) onChanged;

  CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  Future<List<CategoryModel>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromDocument(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final categories = snapshot.data ?? [];
        final dropdownItems = [
          const DropdownMenuItem<String>(
            value: '0', // Value for 'ทั้งหมด'
            child: Text('หมวดหมู่'), 
          ),
          ...categories.map(
            (category) => DropdownMenuItem<String>(
              value: category.id, // Use the category id as value
              child: Text(category.name_th),
            ),
          ),
        ];

        // Ensure `selectedCategory` has a valid value
        String validValue = selectedCategory.isEmpty ? '0' : selectedCategory;

        return DropdownButton<String>(
          value: validValue, // Set the currently selected value
          hint: Text('เลือกประเภท'),
          items: dropdownItems,
          onChanged: onChanged, // Pass the selected value to the callback
        );
      },
    );
  }
}