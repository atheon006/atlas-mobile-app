import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiService {
  static final ApiService _singleton = ApiService._internal();

  factory ApiService() => _singleton;

  ApiService._internal();

  final String baseUrl = 'http://localhost:9000/store/products';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final jsonList = data['products'] as List<dynamic>;
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
