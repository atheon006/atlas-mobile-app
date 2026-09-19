import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalUsd {
    // Application automatique de la remise de gros si quantité suffisante
    double unitPrice = product.priceUsd;
    for (var tier in product.wholesalePrices) {
      if (quantity >= tier.minQty) {
        unitPrice = tier.priceUsd;
      }
    }
    return unitPrice * quantity;
  }

  double get totalCdf {
    double unitPrice = product.priceCdf;
    for (var tier in product.wholesalePrices) {
      if (quantity >= tier.minQty) {
        unitPrice = tier.priceCdf;
      }
    }
    return unitPrice * quantity;
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _currency = 'CDF'; // 'CDF' ou 'USD'

  List<CartItem> get items => _items;
  String get currency => _currency;

  void toggleCurrency() {
    _currency = _currency == 'CDF' ? 'USD' : 'CDF';
    notifyListeners();
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotalUsd =>
      _items.fold(0.0, (sum, item) => sum + item.totalUsd);

  double get grandTotalCdf =>
      _items.fold(0.0, (sum, item) => sum + item.totalCdf);
}
