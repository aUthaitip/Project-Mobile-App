import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/menu_item.dart';
import 'package:teeyai_app/widgets/category_dropdown.dart';

class AllMenuScreen extends StatefulWidget {
  AllMenuScreen({super.key});

  @override
  _AllMenuScreenState createState() => _AllMenuScreenState();
}

class _AllMenuScreenState extends State<AllMenuScreen> {
  final TextEditingController searchController = TextEditingController();
  String selected = '0'; // Default: 'ทั้งหมด'

  Stream<List<MenuItem>> _fetchMenu([String categoryId = '0']) {
    Query collection = FirebaseFirestore.instance.collection('Menus');

    // If selected category is not '0', filter by categoryId.
    if (categoryId != '0') {
      collection = collection.where('category_id', isEqualTo: categoryId);
    } 
    return collection
        .snapshots()
        .handleError((error) {
          // Handle Firebase-related or network-related errors
          print("Error fetching menus: $error");
          // You could also log this error or show a Snackbar here for the user
        })
        .map((snapshot) {
          try {
            // Safely process the snapshot data
            return snapshot.docs.map((doc) {
              return MenuItem.fromDocument(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            }).toList();
          } catch (error) {
            // Catch errors related to data processing
            print("Error processing snapshot data: $error");
            // Return an empty list or handle the error appropriately
            return [];
          }
        });
  }

  void confirmDeleteMenu(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('ยืนยันการลบ'),
            content: Text('คุณต้องการลบเมนู "${item.name}" หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('Menus')
                      .doc(item.id)
                      .delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ลบเมนู "${item.name}" แล้ว')),
                  );
                },
                child: Text('ลบ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void editMenu(BuildContext context, MenuItem item) {
  final nameController = TextEditingController(text: item.name);
  final priceController = TextEditingController(text: item.price.toString());
  final imageUrlController = TextEditingController(text: item.imageUrl ?? '');
  String newCategory = item.category_id;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('แก้ไขเมนู'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'ชื่อเมนู'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'ราคา'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  SizedBox(height: 8),
                  CategoryDropdown(
                    selectedCategory: newCategory,
                    onChanged: (newValue) {
                      setState(() {
                        newCategory = newValue ?? newCategory;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceText = priceController.text.trim();
                  final imageUrl = imageUrlController.text.trim();
                  final price = double.tryParse(priceText);

                  if (name.isEmpty || price == null || newCategory == '0') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('Menus')
                      .doc(item.id)
                      .update({
                        'name': name,
                        'price': price,
                        'imageUrl': imageUrl,
                        'category_id': newCategory,
                      });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขเมนู "$name" แล้ว')),
                  );
                },
                child: Text('บันทึก'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void addMenu(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    String menuCategory = '0';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('เพิ่มเมนู'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'ชื่อเมนู'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'ราคา'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: imageUrlController,
                      decoration: InputDecoration(labelText: 'Image URL'),
                    ),
                    SizedBox(height: 8),
                    CategoryDropdown(
                      selectedCategory: menuCategory,
                      onChanged: (category) {
                        setState(() {
                          menuCategory = category ?? '0';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final priceText = priceController.text.trim();
                    final imageUrl = imageUrlController.text.trim();

                    if (name.isEmpty ||
                        priceText.isEmpty ||
                        menuCategory == '0') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                      );
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('กรุณาใส่ราคาที่ถูกต้อง')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('Menus').add({
                      'name': name,
                      'category_id': menuCategory,
                      'price': price,
                      'imageUrl': imageUrl,
                      'status': 1,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เพิ่ม "$name" แล้ว')),
                    );
                  },
                  child: Text('เพิ่ม'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เมนูทั้งหมด'),
        backgroundColor: Color.fromARGB(255, 232, 77, 74),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () => addMenu(context)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาเมนู...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 8),
                // Category Dropdown
                CategoryDropdown(
                  selectedCategory: selected, // Ensure this is never null
                  onChanged: (category) {
                    setState(() {
                      selected = category ?? '0'; // If null, default to '0'
                      print('Selected category: $selected');

                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<MenuItem>>(
                stream: _fetchMenu(selected), // Pass the selected value
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  final allItems = snapshot.data ?? [];

                  final filteredItems =
                      allItems.where((item) {
                        final searchMatch = item.name.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        );
                        final categoryMatch =
                            selected == '0' || item.category_id == selected;
                        return searchMatch && categoryMatch;
                      }).toList();

                  if (filteredItems.isEmpty) {
                    return Center(child: Text('ไม่มีเมนูที่ตรงกับเงื่อนไข'));
                  }

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
                              item.imageUrl ?? '',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image),
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text('${item.price} บาท'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: item.status == 1,
                              onChanged: (value) async {
                                final newStatus = value ? 1 : 0;
                                await FirebaseFirestore.instance
                                    .collection('Menus')
                                    .doc(item.id)
                                    .update({'status': newStatus});
                                // Optional: You could show a SnackBar confirmation
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.grey,
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editMenu(context, item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDeleteMenu(context, item),
                            ),
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
