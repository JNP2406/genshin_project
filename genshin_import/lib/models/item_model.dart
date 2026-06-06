import 'package:genshin_import/services/api_service.dart';

class ItemModel {
  final int id;
  final String name;
  final String category;
  final String type;
  final String stat;
  final String description;
  final int stock;
  final String image;
  final double price;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.stat,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      type: json['type'],
      stat: json['stat'] ?? '',
      description: json['description'] ?? '',
      stock: json['stock'],
      image: ApiService.buildImageUrl(json['image']),
      price: double.parse(json['price'].toString()),
    );
  }
}