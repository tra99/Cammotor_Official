class StoreBasketModel {
  final int id;
  final int total;
  final String status;
  final int userID;
  final String paymentID;
  final String createdAt;
  final String updatedAt;

  StoreBasketModel({
    required this.id,
    required this.total,
    required this.status,
    required this.userID,
    required this.paymentID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreBasketModel.fromJson(Map<String, dynamic> json) {
    return StoreBasketModel(
      id: json['id'],
      total: json['total'],
      status: json['status'],
      userID: json['userID'],
      paymentID: json['paymentID'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
