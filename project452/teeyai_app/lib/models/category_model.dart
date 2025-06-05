import 'package:cloud_firestore/cloud_firestore.dart';


class CategoryModel {
  final String id;
  final String name_th;
  final String name_eng;
  final String? imageUrl;


 

  CategoryModel({
    required this.id,
    required this.name_th,
    required this.name_eng,
    this.imageUrl,
 
    
  });

  
 factory CategoryModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return CategoryModel(
    id: doc.id,
    name_th: data['name_th'] ?? '',
    name_eng: data['name_eng'] ?? '',
    imageUrl: data['imageUrl'],
  );
}


 Map<String, dynamic> toMap() {
    return {
     
      'name_th': name_th,
      'name_eng': name_eng,
      'imageUrl': imageUrl,
    };
  }

}