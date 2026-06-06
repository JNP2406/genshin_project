class TransactionModel {
  final int id;
  final int userId;
  final int itemId;
  final String itemName;
  final String itemImage;
  final String itemType;
  final int quantity;
  final double totalPrice;
  final String createdAt;
  final String? userName;
  final String? userEmail;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.itemType,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemImage: json['item_image'] ?? '',
      itemType: json['item_type'] ?? '',
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: json['created_at'],
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }
}