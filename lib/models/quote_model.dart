class QuoteModel {
  final String id;
  final String buyerId;
  final String vendorId;
  final String? productId;
  final String productTitle;
  final int requestedQuantity;
  final double? targetPriceUsd;
  final double? offeredPriceUsd;
  final String status;
  final String? message;
  final String? vendorReply;
  final String createdAt;

  QuoteModel({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    this.productId,
    required this.productTitle,
    required this.requestedQuantity,
    this.targetPriceUsd,
    this.offeredPriceUsd,
    required this.status,
    this.message,
    this.vendorReply,
    required this.createdAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      productId: json['product_id'],
      productTitle: json['product_title'] ?? 'Demande de Gros',
      requestedQuantity: json['requested_quantity'] ?? 10,
      targetPriceUsd: json['target_price_usd'] != null
          ? (json['target_price_usd'] as num).toDouble()
          : null,
      offeredPriceUsd: json['offered_price_usd'] != null
          ? (json['offered_price_usd'] as num).toDouble()
          : null,
      status: json['status'] ?? 'pending',
      message: json['message'],
      vendorReply: json['vendor_reply'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
