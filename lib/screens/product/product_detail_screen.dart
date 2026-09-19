import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../rfq/request_quote_modal.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isCdf = cart.currency == 'CDF';

    final String priceText = isCdf
        ? '${product.priceCdf.toStringAsFixed(0)} FC'
        : '\$${product.priceUsd.toStringAsFixed(2)}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image de présentation avec AppBar flottante
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Contenu produit
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Catégorie
                  if (product.category != null)
                    Chip(
                      label: Text(product.category!),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryColor),
                    ),

                  const SizedBox(height: 8),

                  // Titre du produit
                  Text(
                    product.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Prix principal
                  Row(
                    children: [
                      Text(
                        priceText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stock: ${product.stock} dispo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tableau des Prix Dégressifs de Gros (Alibaba Style)
                  if (product.wholesalePrices.isNotEmpty) ...[
                    Text(
                      'Tarifs Dégressifs Achat en Gros',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentColor.withOpacity(0.5)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: product.wholesalePrices.map((tier) {
                          final tierPrice = isCdf
                              ? '${tier.priceCdf.toStringAsFixed(0)} FC'
                              : '\$${tier.priceUsd.toStringAsFixed(2)}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'À partir de ${tier.minQty} unités',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$tierPrice / unité',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Text(
                    'Description du produit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'Aucune description fournie par le vendeur.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton Demande de Devis (RFQ) pour Vente en Gros
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => RequestQuoteModal(product: product),
                      );
                    },
                    icon: const Icon(Icons.request_quote, color: AppTheme.primaryColor),
                    label: Text(
                      'Négocier un Devis / Achat en Gros (RFQ)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              cart.addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produit ajouté au panier !')),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Ajouter au Panier'),
          ),
        ),
      ),
    );
  }
}
