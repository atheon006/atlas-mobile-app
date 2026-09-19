import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'mpesa';
  final _phoneController = TextEditingController(text: '+243990000000');
  final _addressController = TextEditingController(text: 'Kinshasa, Gombe, Av. de la Justice N°14');
  bool _isProcessing = false;

  final Map<String, Map<String, String>> _paymentMethods = {
    'mpesa': {'name': 'M-Pesa (Vodacom)', 'icon': '📲'},
    'airtel_money': {'name': 'Airtel Money', 'icon': '🔴'},
    'orange_money': {'name': 'Orange Money', 'icon': '🟠'},
    'flexpay': {'name': 'FlexPay (Carte / Mobile)', 'icon': '💳'},
  };

  Future<void> _processPayment(CartProvider cart) async {
    if (cart.items.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final firstVendorId = cart.items.first.product.vendorId;

      final order = await SupabaseService.createOrderWithKPay(
        vendorId: firstVendorId,
        totalCdf: cart.grandTotalCdf,
        totalUsd: cart.grandTotalUsd,
        currency: cart.currency,
        paymentMethod: _selectedPaymentMethod,
        phone: _phoneController.text,
        shippingAddress: {
          'address': _addressController.text,
          'phone': _phoneController.text,
        },
        items: cart.items
            .map((e) => {
                  'product_id': e.product.id,
                  'quantity': e.quantity,
                  'unit_price_cdf': e.product.priceCdf,
                  'unit_price_usd': e.product.priceUsd,
                })
            .toList(),
      );

      if (mounted) {
        cart.clearCart();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paiement KPay (${_paymentMethods[_selectedPaymentMethod]!['name']}) effectué avec succès !',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Paiement: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isCdf = cart.currency == 'CDF';

    final String grandTotalText = isCdf
        ? '${cart.grandTotalCdf.toStringAsFixed(0)} FC'
        : '\$${cart.grandTotalUsd.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Panier & Caisse',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Articles du panier
                  Text(
                    'Articles Sélectionnés (${cart.totalItemCount})',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final itemPriceText = isCdf
                          ? '${item.totalCdf.toStringAsFixed(0)} FC'
                          : '\$${item.totalUsd.toStringAsFixed(2)}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.images.first,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      itemPriceText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () => cart.updateQuantity(
                                      item.product.id,
                                      item.quantity - 1,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () => cart.updateQuantity(
                                      item.product.id,
                                      item.quantity + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Mode de Paiement KPay Mobile Money
                  Text(
                    'Paiement KPay (Mobile Money RDC)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: _paymentMethods.entries.map((entry) {
                      final isSelected = _selectedPaymentMethod == entry.key;
                      return Card(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: entry.key,
                          groupValue: _selectedPaymentMethod,
                          activeColor: AppTheme.primaryColor,
                          title: Text(
                            '${entry.value['icon']}  ${entry.value['name']}',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPaymentMethod = val);
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Champ Téléphone Mobile Money
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro de Téléphone Mobile Money (+243...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Champ Adresse de livraison
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresse de Livraison (Ville, Quartier, Av.)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Résumé du Total & Bouton de Paiement
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total à payer :',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          grandTotalText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _processPayment(cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Payer $grandTotalText via KPay',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
