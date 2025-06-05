import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teeyai_app/models/order_model.dart';
import  'package:teeyai_app/models/menu_item.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, MenuItem> _menuMap = {};
  bool _menuLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //  chunk the list of menu IDs into smaller lists of 10
  List<List<String>> _chunk(List<String> list, int chunkSize) {
    List<List<String>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  // Function to load menu items based on the unique menu IDs in the orders
  Future<void> _loadMenuItems(List<String> menuIds) async {
    try {
      final chunkedMenuIds = _chunk(menuIds, 10); // Split the IDs into chunks of 10
      for (var chunk in chunkedMenuIds) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Menus')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final menuList = snapshot.docs.map((doc) {
          print("Loaded Menu: ${doc.id} -> ${doc.data()}");
          return MenuItem.fromDocument(doc.id, doc.data());
        }).toList();

        setState(() {
          _menuMap.addAll({for (var item in menuList) item.id: item});
          _menuLoaded = true;
        });
      }
    } catch (e) {
      print("Error loading menu items: $e");
    }
  }

 Stream<List<OrderModel>> _fetchOrdersByStatuses(List<String> statuses) {
  return FirebaseFirestore.instance
      .collection('Orders')
      .where('status', whereIn: statuses)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        Set<String> menuIds = {};
        for (var doc in snapshot.docs) {
          final order = OrderModel.fromDocument(doc.id, doc.data());
          menuIds.addAll(order.items.keys);
        }
        _loadMenuItems(menuIds.toList());

        return snapshot.docs
            .map((doc) => OrderModel.fromDocument(doc.id, doc.data()))
            .toList();
      });
}


  void _markAsComplete(String orderId) {
    FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'status': 'completed',
    });
  }

  void _markAsCanceled(String orderId) {
    FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'status': 'canceled',
    });
  }

Widget _buildOrderList(
  Stream<List<OrderModel>> stream,
  bool showActionButton,
) {
  return StreamBuilder<List<OrderModel>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final orders = snapshot.data!;
      if (orders.isEmpty) return const Center(child: Text('No orders'));

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, index) {
          final order = orders[index];
          final statusText = showActionButton
              ? 'Pending'
              : (order.status == 'completed' ? 'Completed' : 'Canceled');

          final statusColor = showActionButton
              ? Colors.orange
              : (order.status == 'completed'
                  ? Colors.green
                  : Colors.red);

          return GestureDetector(
            onTap: () {
              _showOrderDetailsDialog(order, showActionButtons: showActionButton);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Order details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🧾 Order ID: ${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('🍽️ โต๊ะ: ${order.tableNo}'),
                        Text('💵 ฿${order.totalPrice.toStringAsFixed(2)}'),
                        Text('🕒 เวลา: ${order.timestamp.toLocal().toString().substring(0, 19)}'),
                      ],
                    ),
                  ),
                  // Right: Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


void _showOrderDetailsDialog(OrderModel order, {bool showActionButtons = true}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '🧾 Order: ${order.id}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Text('🍽️ โต๊ะ: ${order.tableNo}', style: const TextStyle(fontSize: 14)),
    ],
  ),
  content: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          '🕒 เวลา: ${order.timestamp.toLocal().toString().substring(0, 19)}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text(
          '📋 รายการอาหาร',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...List.from(order.items.entries).asMap().entries.map((entry) {
          final index = entry.key + 1; // Adds 1 to start numbering from 1
          final menuId = entry.value.key;
          final qty = entry.value.value;
          final menuItem = _menuMap[menuId];
          final name = menuItem?.name ?? 'Unknown';
          final price = menuItem?.price ?? 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '$index. $name x $qty = ฿${(price * qty).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
        const SizedBox(height: 16),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('รวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('฿${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        // Status label
        if (order.status == 'canceled')
          const Text(
            'สถานะ: ยกเลิกแล้ว',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        if (order.status == 'completed')
          const Text(
            'สถานะ: เสร็จสิ้น',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        // Action buttons
        if (showActionButtons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _markAsCanceled(order.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('ยกเลิก'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _markAsComplete(order.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('เสร็จสิ้น'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
      ],
    ),
  ),
);


    },
  );
}



  // Popup Dialog to view order details


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติรายการ',
            style: TextStyle(
              fontFamily: 'NotoSansThai',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromARGB(255, 232, 77, 74),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'รอดำเนินการ'), Tab(text: 'เสร็จสิ้นแล้ว')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
         _buildOrderList(_fetchOrdersByStatuses(['pending']), true),
         _buildOrderList(_fetchOrdersByStatuses(['completed', 'canceled']), false),
        ],
      ),
    );
  }
}
