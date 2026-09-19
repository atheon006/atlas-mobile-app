import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/quote_model.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ==================================================================
  // AUTHENTIFICATION : SEULEMENT GOOGLE SIGN-IN
  // ==================================================================
  static Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // OAuth Google direct sur le Web
        return await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'com.atlas.app://login-callback',
        );
      } else {
        // Google Sign-In Native sur Android/iOS
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false; // Annulé par l'utilisateur

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          throw Exception('Impossible d\'obtenir le jeton ID Google.');
        }

        final response = await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        return response.user != null;
      }
    } catch (e) {
      debugPrint('Erreur Connexion Google: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // ==================================================================
  // PRODUITS & CATALOGUE MULTI-VENDEURS
  // ==================================================================
  static Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      var query = client.from('products').select('*').eq('is_published', true);
      if (category != null && category != 'Tous') {
        query = query.eq('category', category);
      }

      final data = await query.order('created_at', ascending: false);
      return (data as List).map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erreur de récupération des produits: $e');
      // Produits factices si la base de données vient d'être initialisée
      return _getMockProducts();
    }
  }

  // ==================================================================
  // DEMANDES DE DEVIS (RFQ POUR VENTE EN GROS)
  // ==================================================================
  static Future<bool> createQuoteRequest({
    required String vendorId,
    required String? productId,
    required String productTitle,
    required int requestedQuantity,
    required double targetPriceUsd,
    required String message,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      await client.from('quotes').insert({
        'buyer_id': user.id,
        'vendor_id': vendorId,
        'product_id': productId,
        'product_title': productTitle,
        'requested_quantity': requestedQuantity,
        'target_price_usd': targetPriceUsd,
        'status': 'pending',
        'message': message,
      });
      return true;
    } catch (e) {
      debugPrint('Erreur création devis: $e');
      return false;
    }
  }

  // ==================================================================
  // COMMANDES & PAIEMENT KPAY
  // ==================================================================
  static Future<OrderModel?> createOrderWithKPay({
    required String vendorId,
    required double totalCdf,
    required double totalUsd,
    required String currency,
    required String paymentMethod, // 'mpesa', 'airtel_money', 'orange_money'
    required String phone,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = currentUser;
    final userId = user?.id ?? 'guest-user-id';

    try {
      // 1. Création de la commande
      final orderResponse = await client.from('orders').insert({
        'buyer_id': userId,
        'vendor_id': vendorId,
        'total_cdf': totalCdf,
        'total_usd': totalUsd,
        'currency': currency,
        'status': 'pending',
        'shipping_address': shippingAddress,
      }).select().single();

      final String orderId = orderResponse['id'];

      // 2. Création de la transaction de paiement KPay
      await client.from('payments').insert({
        'order_id': orderId,
        'kpay_transaction_id': 'KPAY-${DateTime.now().millisecondsSinceEpoch}',
        'payment_method': paymentMethod,
        'amount': currency == 'CDF' ? totalCdf : totalUsd,
        'currency': currency,
        'status': 'completed', // Simulation validée KPay
      });

      return OrderModel.fromJson(orderResponse);
    } catch (e) {
      debugPrint('Erreur création commande KPay: $e');
      rethrow;
    }
  }

  static List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-kinshasa',
        title: 'Bazin Riche Brodé VIP (Rouleaux 10 Yards)',
        slug: 'bazin-riche-vip',
        description: 'Bazin de haute qualité importé, idéal pour cérémonies et couturiers.',
        category: 'Mode & Tissus',
        priceCdf: 350000.0,
        priceUsd: 125.0,
        stock: 45,
        wholesalePrices: [
          WholesalePriceTier(minQty: 5, priceUsd: 110.0, priceCdf: 308000.0),
          WholesalePriceTier(minQty: 10, priceUsd: 95.0, priceCdf: 266000.0),
        ],
        images: ['https://images.unsplash.com/photo-1584917865442-de89df76afd3'],
        isPublished: true,
      ),
      ProductModel(
        id: 'prod-2',
        vendorId: 'vendor-goma',
        title: 'Panneaux Solaire 550W Monocristallin',
        slug: 'panneau-solaire-550w',
        description: 'Panneau solaire haute efficacité pour maisons et commerces.',
        category: 'Énergie & Électronique',
        priceCdf: 420000.0,
        priceUsd: 150.0,
        stock: 120,
        wholesalePrices: [
          WholesalePriceTier(minQty: 10, priceUsd: 130.0, priceCdf: 364000.0),
          WholesalePriceTier(minQty: 50, priceUsd: 115.0, priceCdf: 322000.0),
        ],
        images: ['https://images.unsplash.com/photo-1509391365360-2e959784a276'],
        isPublished: true,
      ),
      ProductModel(
        id: 'prod-3',
        vendorId: 'vendor-lubumbashi',
        title: 'Sac de Ciment 50kg (Lot Gros 100 Sacs)',
        slug: 'sac-ciment-gros',
        description: 'Ciment Portland certifié pour chantiers de construction.',
        category: 'Matériaux de Construction',
        priceCdf: 30800.0,
        priceUsd: 11.0,
        stock: 500,
        wholesalePrices: [
          WholesalePriceTier(minQty: 100, priceUsd: 9.5, priceCdf: 26600.0),
        ],
        images: ['https://images.unsplash.com/photo-1589939705384-5185137a7f0f'],
        isPublished: true,
      ),
    ];
  }
}
