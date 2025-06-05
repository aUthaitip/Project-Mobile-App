class MenuItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category_id;
  final int status;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category_id,
    required this.status,
  });

  factory MenuItem.fromDocument(String id, Map<String, dynamic> data) {
    return MenuItem(
      id: id,
      name: data['name'],
      price: data['price'].toDouble(),
      imageUrl: data['imageUrl'],
      category_id: data['category_id'],
      status: data['status'] ?? 0,);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'category_id': category_id,
      'status': status,
    };
  }
}
