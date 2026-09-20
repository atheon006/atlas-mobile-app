import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _currency = 'CDF'; // CDF ou USD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ATLAS MARKETPLACE',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: const Color(0xFF8A002E),
          ),
        ),
        actions: [
          // Bascule de Devise (CDF / USD)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _currency = _currency == 'CDF' ? 'USD' : 'CDF';
              });
            },
            icon: const Icon(Icons.currency_exchange, size: 18),
            label: Text(
              _currency,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: ApiService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: products[index],
                  currency: _currency,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Impossible de charger le catalogue ATLAS: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8A002E)),
          );
        },
      ),
    );
  }
}
