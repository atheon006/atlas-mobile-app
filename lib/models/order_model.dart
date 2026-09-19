class OrderItemModel {
  final String id;
  final String productId;
  final String productTitle;
  final int quantity;
  final double unitPriceCdf;
  final double unitPriceUsd;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.quantity,
    required this.unitPriceCdf,
    required this.unitPriceUsd,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productTitle: json['products']?['title'] ?? 'Article ATLAS',
      quantity: json['quantity'] ?? 1,
      unitPriceCdf: (json['unit_price_cdf'] ?? 0.0).toDouble(),
      unitPriceUsd: (json['unit_price_usd'] ?? 0.0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final String vendorId;
  final String? driverId;
  final double totalCdf;
  final double totalUsd;
  final String currency;
  final String status;
  final Map<String, dynamic> shippingAddress;
  final String? otpCode; // Code de séquestre à 4 chiffres (ex: 8492)
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    this.driverId,
    required this.totalCdf,
    required this.totalUsd,
    required this.currency,
    required this.status,
    required this.shippingAddress,
    this.otpCode,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['order_items'];
    List<OrderItemModel> itemList = [];
    if (rawItems is List) {
      itemList = rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      driverId: json['driver_id'],
      totalCdf: (json['total_cdf'] ?? 0.0).toDouble(),
      totalUsd: (json['total_usd'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'CDF',
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'] is Map<String, dynamic>
          ? json['shipping_address']
          : {},
      otpCode: json['otp_code'] ?? '8492', // Code par défaut de séquestre
      createdAt: json['created_at'] ?? '',
      items: itemList,
    );
  }
}
