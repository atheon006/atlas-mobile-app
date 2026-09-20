class Product {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final String handle;
  final String status;
  final String thumbnail;
  final double weight;
  final List<ProductVariant> variants;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.title,
    this.subtitle,
    required this.description,
    required this.handle,
    required this.status,
    required this.thumbnail,
    required this.weight,
    required this.variants,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<ProductVariant> variants = [];
    List<ProductImage> images = [];

    for (final variant in json['variants']) {
      variants.add(ProductVariant.fromJson(variant));
    }

    for (final image in json['images']) {
      images.add(ProductImage.fromJson(image));
    }

    return Product(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      handle: json['handle'],
      status: json['status'],
      thumbnail: json['thumbnail'],
      weight: json['weight'].toDouble(),
      variants: variants,
      images: images,
    );
  }
}

class ProductVariant {
  final String id;
  final String title;
  final double inventoryQuantity;
  final List<ProductPrice> prices;

  ProductVariant({
    required this.id,
    required this.title,
    required this.inventoryQuantity,
    required this.prices,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    List<ProductPrice> prices = [];

    for (final price in json['prices']) {
      prices.add(ProductPrice.fromJson(price));
    }

    return ProductVariant(
      id: json['id'],
      title: json['title'],
      inventoryQuantity: json['inventory_quantity'].toDouble(),
      prices: prices,
    );
  }
}

class ProductPrice {
  final String id;
  final String currencyCode;
  final double amount;

  ProductPrice({
    required this.id,
    required this.currencyCode,
    required this.amount,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      id: json['id'],
      currencyCode: json['currency_code'],
      amount: json['amount'].toDouble(),
    );
  }
}

class ProductImage {
  final String id;
  final String url;

  ProductImage({
    required this.id,
    required this.url,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
    );
  }
}
