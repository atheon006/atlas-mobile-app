# 🏛️ ATLAS Marketplace Mobile App (Medusa Storefront Core)

Application mobile officielle pour **ATLAS Marketplace RDC** — Plateforme E-Commerce multi-vendeurs et Vente en Gros (RFQ), dérivée de l'architecture Storefront MedusaJS Flutter.

---

## 📌 Présentation

**ATLAS Mobile App** est l'application cliente principale pour le marché congolais (Kinshasa, Goma, Lubumbashi).

### 🔑 Fonctionnalités Clés :
* **Storefront MedusaJS / Supabase** : Catalogue produits réactif.
* **Connexion 100% Google** : Connexion exclusive via Google Sign-In.
* **Paiement Local KPay** : Prise en charge de M-Pesa, Airtel Money, Orange Money & FlexPay.
* **Multi-Devises RDC** : Bascule dynamique entre Franc Congolais (**CDF**) et Dollar Américain (**USD**).
* **Achats en Gros & Devis (RFQ)** : Module de négociation de tarifs dégressifs.
* **Code OTP Séquestre** : Génération d'un code secret à 4 chiffres (ex: `8492`) pour sécuriser la remise du colis par le livreur.

---

## 📸 Identité Visuelle (Logo Official)

Le logo officiel ATLAS est disponible dans `assets/images/logo.jpg`.

---

## 🛠️ Stack Technique

* **Framework** : Flutter 3.x (Dart)
* **Design System** : Material 3, couleur bordeaux signature `#8A002E` & or `#D4AF37`.
* **Backend** : Supabase Cloud (`zywtmanjdfhnibmdjeey`) + Medusa Store APIs.

---

## 🚀 Installation & Lancement

```bash
# 1. Cloner le dépôt
git clone https://github.com/atheon006/atlas-mobile-app.git
cd atlas-mobile-app

# 2. Obtenir les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

---

## 🏗️ Compilation Automatique (.APK)

Ce dépôt intègre un workflow GitHub Actions (`.github/workflows/build-android.yml`) qui génère automatiquement le fichier `.APK` Android à chaque push sur la branche `main`.
