class WholesalePriceTier {
  final int minQty;
  final double priceUsd;
  final double priceCdf;

  WholesalePriceTier({
    required this.minQty,
    required this.priceUsd,
    required this.priceCdf,
  });

  factory WholesalePriceTier.fromJson(Map<String, dynamic> json) {
    return WholesalePriceTier(
      minQty: json['min_qty'] ?? 1,
      priceUsd: (json['price_usd'] ?? 0.0).toDouble(),
      priceCdf: (json['price_cdf'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'min_qty': minQty,
        'price_usd': priceUsd,
        'price_cdf': priceCdf,
      };
}

class ProductModel {
  final String id;
  final String vendorId;
  final String title;
  final String slug;
  final String? description;
  final String? category;
  final double priceCdf;
  final double priceUsd;
  final List<WholesalePriceTier> wholesalePrices;
  final int stock;
  final List<String> images;
  final bool isPublished;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.slug,
    this.description,
    this.category,
    required this.priceCdf,
    required this.priceUsd,
    required this.wholesalePrices,
    required this.stock,
    required this.images,
    required this.isPublished,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawWholesale = json['wholesale_prices'];
    List<WholesalePriceTier> wholesaleList = [];
    if (rawWholesale is List) {
      wholesaleList = rawWholesale
          .map((e) => WholesalePriceTier.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    var rawImages = json['images'];
    List<String> imgList = [];
    if (rawImages is List) {
      imgList = rawImages.map((e) => e.toString()).toList();
    }

    return ProductModel(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      category: json['category'],
      priceCdf: (json['price_cdf'] ?? 0.0).toDouble(),
      priceUsd: (json['price_usd'] ?? 0.0).toDouble(),
      wholesalePrices: wholesaleList,
      stock: json['stock'] ?? 0,
      images: imgList.isEmpty
          ? ['https://images.unsplash.com/photo-1523275335684-37898b6baf30']
          : imgList,
      isPublished: json['is_published'] ?? true,
    );
  }
}
