import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../system_manager.dart';

enum PremiumStatus {
  initial,
  loading,
  ready,
  purchasing,
  restoring,
  active,
  error,
}

class PremiumManager extends ChangeNotifier {

  // MUST match Play Console exactly
  static const String monthlyId = "scam_kavatch_monthly";
  static const String yearlyId  = "scam_kavatch_yearly";

  static const Set<String> productIds = {
    monthlyId,
    yearlyId,
  };

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumStatus status = PremiumStatus.initial;

  bool isPremium = false;

  bool showPremiumSuccess = false;

  String? lastError;

  bool _storeAvailable = false;

  List<ProductDetails> _products = [];

  bool _initialized = false;

  PremiumManager() {
    _init();
  }

  // ================= INIT =================

  Future<void> _init() async {

    if (_initialized) return;
    _initialized = true;

    try {

      status = PremiumStatus.loading;
      notifyListeners();

      await _loadSavedPremium();

      _storeAvailable = await _iap.isAvailable();

      if (!_storeAvailable) {

        lastError = "Billing unavailable";
        status = PremiumStatus.error;
        notifyListeners();
        return;
      }

      _subscription?.cancel();

      _subscription =
          _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onError: (e) {
          lastError = e.toString();
          status = PremiumStatus.error;
          notifyListeners();
        },
      );

      await _loadProducts();

      await restore();

      status = isPremium
          ? PremiumStatus.active
          : PremiumStatus.ready;

      notifyListeners();

    } catch (e) {

      lastError = e.toString();
      status = PremiumStatus.error;
      notifyListeners();
    }
  }

  // ================= LOAD SAVED PREMIUM =================

  Future<void> _loadSavedPremium() async {

    final prefs =
        await SharedPreferences.getInstance();

    isPremium =
        prefs.getBool("isPremium") ?? false;

    // CRITICAL: Sync protection engine
    await SystemManager.setPremium(isPremium);
  }

  // ================= SAVE PREMIUM =================

  Future<void> _savePremium(bool value) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool("isPremium", value);
  }

  // ================= LOAD PRODUCTS =================

  Future<void> _loadProducts() async {

    final response =
        await _iap.queryProductDetails(productIds);

    if (response.error != null) {

      lastError = response.error!.message;
      status = PremiumStatus.error;
      notifyListeners();
      return;
    }

    _products = response.productDetails;
  }

  // ================= BUY =================

  Future<void> buyPremium(String id) async {

    if (status == PremiumStatus.purchasing) {
      return;
    }

    try {

      final product =
          _products.firstWhere(
        (p) => p.id == id,
      );

      status = PremiumStatus.purchasing;
      notifyListeners();

      await _iap.buyNonConsumable(
        purchaseParam:
            PurchaseParam(productDetails: product),
      );

    } catch (e) {

      lastError = e.toString();
      status = PremiumStatus.error;
      notifyListeners();
    }
  }

  // ================= RESTORE =================

  Future<void> restore() async {

    if (status == PremiumStatus.restoring) {
      return;
    }

    status = PremiumStatus.restoring;
    notifyListeners();

    await _iap.restorePurchases();
  }

  // ================= PURCHASE HANDLER =================

  Future<void> _onPurchaseUpdated(
      List<PurchaseDetails> purchases) async {

    for (final purchase in purchases) {

      if (purchase.status ==
              PurchaseStatus.purchased ||
          purchase.status ==
              PurchaseStatus.restored) {

        await _activatePremium();

        if (purchase.pendingCompletePurchase) {

          await _iap.completePurchase(purchase);
        }
      }

      if (purchase.status ==
          PurchaseStatus.error) {

        lastError =
            purchase.error?.message ??
                "Purchase failed";

        status = PremiumStatus.error;
        notifyListeners();
      }
    }
  }

  // ================= ACTIVATE PREMIUM =================

  Future<void> _activatePremium() async {

    isPremium = true;

    showPremiumSuccess = true;

    await _savePremium(true);

    // CRITICAL: enable protection engine
    await SystemManager.setPremium(true);

    status = PremiumStatus.active;

    notifyListeners();
  }

  // ================= CLEAR SUCCESS FLAG =================

  void clearPremiumSuccessFlag() {

    showPremiumSuccess = false;

    notifyListeners();
  }

  // ================= CLEANUP =================

  @override
  void dispose() {

    _subscription?.cancel();

    super.dispose();
  }
}