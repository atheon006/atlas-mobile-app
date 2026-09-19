import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class RequestQuoteModal extends StatefulWidget {
  final ProductModel product;

  const RequestQuoteModal({super.key, required this.product});

  @override
  State<RequestQuoteModal> createState() => _RequestQuoteModalState();
}

class _RequestQuoteModalState extends State<RequestQuoteModal> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController(text: '50');
  final _targetPriceController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Proposer un prix cible par défaut avec 10% de réduction
    final defaultTarget = (widget.product.priceUsd * 0.9).toStringAsFixed(2);
    _targetPriceController.text = defaultTarget;
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await SupabaseService.createQuoteRequest(
        vendorId: widget.product.vendorId,
        productId: widget.product.id,
        productTitle: widget.product.title,
        requestedQuantity: int.parse(_qtyController.text),
        targetPriceUsd: double.parse(_targetPriceController.text),
        message: _messageController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Votre demande de devis a été envoyée au vendeur avec succès !'
                  : 'Demande de devis enregistrée !',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Demande de Devis (RFQ)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            Text(
              widget.product.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 16),

            // Quantité souhaitée
            TextFormField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité souhaitée en gros',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),

            const SizedBox(height: 14),

            // Prix Unitaire Cible ($ USD)
            TextFormField(
              controller: _targetPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Prix unitaire proposé (\$ USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),

            const SizedBox(height: 14),

            // Message au vendeur
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message ou conditions au vendeur',
                hintText: 'Ex: Livraison souhaitée à Kinshasa d\'ici 5 jours...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Envoyer la demande au Vendeur',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
