import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController searchController = TextEditingController();

  Stream<List<CategoryModel>> _fetchCategory() {
    return FirebaseFirestore.instance
        .collection('Categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromDocument(doc))
            .toList());
  }

  void confirmDeleteCategory(BuildContext context, CategoryModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบหมวดหมู่ "${item.name_th}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('Categories')
                  .doc(item.id)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบ "${item.name_th}" แล้ว')),
              );
            },
            child: Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editCategory(BuildContext context, CategoryModel item) {
    final nameTHController = TextEditingController(text: item.name_th);
    final nameEngController = TextEditingController(text: item.name_eng);
    final imageUrlController = TextEditingController(text: item.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('แก้ไขหมวดหมู่'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameTHController, decoration: InputDecoration(labelText: 'ชื่อหมวดหมู่')),
              TextField(controller: nameEngController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('ยกเลิก')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('Categories')
                  .doc(item.id)
                  .update({
                'name_th': nameTHController.text,
                'name_eng': nameEngController.text,
                'imageUrl': imageUrlController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('แก้ไข "${nameTHController.text}" แล้ว')),
              );
            },
            child: Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void addCategory(BuildContext context) {
    final nameTHController = TextEditingController();
    final nameEngController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เพิ่มหมวดหมู่ใหม่'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameTHController, decoration: InputDecoration(labelText: 'ชื่อหมวดหมู่')),
              TextField(controller: nameEngController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('ยกเลิก')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('Categories').add({
                'name_th': nameTHController.text,
                'name_eng': nameEngController.text,
                'imageUrl': imageUrlController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เพิ่ม "${nameTHController.text}" แล้ว')),
              );
            },
            child: Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หมวดหมู่ทั้งหมด', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Color.fromARGB(255, 232, 77, 74),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addCategory(context),
            tooltip: 'เพิ่มหมวดหมู่ใหม่',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหา...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                stream: _fetchCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('ไม่มีหมวดหมู่'));
                  }

                  final categories = snapshot.data!;
                  final query = searchController.text.toLowerCase();
                  final filteredItems = categories.where((cat) =>
                    cat.name_th.toLowerCase().contains(query) ||
                    cat.name_eng.toLowerCase().contains(query)).toList();

                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl?.isNotEmpty == true ? item.imageUrl! : 'https://via.placeholder.com/56',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                            ),
                          ),
                          title: Text(item.name_th),
                          subtitle: Text(item.name_eng),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => editCategory(context, item)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDeleteCategory(context, item)),
                            ],
                          ),
                        ),
                      );
                    },
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