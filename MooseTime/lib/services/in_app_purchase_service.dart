import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Create matching consumable products in both mobile stores.
const tipProductLabels = {
  'moosetime_tip_099': 'Small Tip',
  'moosetime_tip_299': 'Support MooseTime',
  'moosetime_tip_499': 'Big Tip',
  'moosetime_tip_999': 'Huge Support',
};

// Small adapter keeps store calls separate and permits tests without real charges.
abstract class TipStore {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProducts(Set<String> ids);
  Future<bool> buyConsumable(ProductDetails product);
  Future<void> completePurchase(PurchaseDetails purchase);
}

class NativeTipStore implements TipStore {
  final InAppPurchase _store = InAppPurchase.instance;
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;
  @override
  Future<bool> isAvailable() => _store.isAvailable();
  @override
  Future<ProductDetailsResponse> queryProducts(Set<String> ids) =>
      _store.queryProductDetails(ids);
  @override
  Future<bool> buyConsumable(ProductDetails product) => _store.buyConsumable(
    purchaseParam: PurchaseParam(productDetails: product),
    autoConsume: true,
  );
  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _store.completePurchase(purchase);
}

class InAppPurchaseService extends ChangeNotifier {
  InAppPurchaseService({
    this.store,
    this.supportedPlatformOverride,
    this.verifyPurchase,
  });

  // App-session ownership: closing Support does not stop transaction completion.
  static final instance = InAppPurchaseService();
  final bool? supportedPlatformOverride;
  TipStore? store;
  TipStore get _nativeStore => store ??= NativeTipStore();
  // Optional future server verification hook. No receipts/tokens are logged.
  final Future<bool> Function(PurchaseDetails purchase)? verifyPurchase;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void> _updates = Future.value();
  final Map<String, PurchaseDetails> _unfinished = {};
  final Set<String> _processed = {};
  bool _disposed = false;
  bool loading = false;
  bool storeAvailable = false;
  bool confirming = false;
  String? pendingProductId;
  String? errorMessage;
  String? notice;
  int noticeNumber = 0;
  List<ProductDetails> products = [];
  Set<String> missingProductIds = {};

  bool get supportedPlatform =>
      supportedPlatformOverride ??
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS));
  bool get hasUnfinishedPurchases => _unfinished.isNotEmpty;
  bool get busy =>
      pendingProductId != null || confirming || hasUnfinishedPurchases;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _notice(String message) {
    notice = message;
    noticeNumber++;
    _notify();
  }

  Future<void> initialize() async {
    if (_disposed || loading) return;
    if (!supportedPlatform) {
      debugPrint('MooseTime tips: mobile store unavailable on this platform.');
      _notify();
      return;
    }
    loading = true;
    errorMessage = null;
    _notify();
    try {
      // Listen before checking availability or loading products.
      _subscription ??= _nativeStore.purchaseStream.listen(
        (purchases) {
          _updates = _updates
              .then((_) async {
                for (final purchase in purchases) {
                  if (_disposed) return;
                  await _handlePurchase(purchase);
                }
              })
              .catchError((Object error, StackTrace stack) {
                debugPrint(
                  'MooseTime tips: purchase processing failed (${error.runtimeType}).',
                );
                _notice(
                  'Could not confirm the tip. Please retry confirmation.',
                );
              });
        },
        onError: (Object error) {
          debugPrint(
            'MooseTime tips: purchase stream error (${error.runtimeType}).',
          );
          _notice(
            'The store connection was interrupted. Please reopen the app to check pending tips.',
          );
        },
      );
      storeAvailable = await _nativeStore.isAvailable();
      if (!storeAvailable) {
        debugPrint('MooseTime tips: store unavailable.');
        products = [];
        errorMessage = 'Tips are currently unavailable on this device.';
        return;
      }
      final response = await _nativeStore.queryProducts(
        tipProductLabels.keys.toSet(),
      );
      if (response.error != null) {
        debugPrint(
          'MooseTime tips: product query failed (${response.error!.code}).',
        );
        errorMessage = 'Could not load tip options. Please try again.';
        return;
      }
      final found = {
        for (final product in response.productDetails) product.id: product,
      };
      products = [
        for (final id in tipProductLabels.keys)
          if (found.containsKey(id)) found[id]!,
      ];
      missingProductIds = tipProductLabels.keys.toSet().difference(
        found.keys.toSet(),
      );
      for (final id in missingProductIds) {
        debugPrint(
          'MooseTime tips: product not found: $id. Check store configuration.',
        );
      }
      if (products.isEmpty) {
        errorMessage =
            'Tip options are not available yet. Please try again later.';
      }
    } catch (error) {
      debugPrint(
        'MooseTime tips: store/product loading failed (${error.runtimeType}).',
      );
      errorMessage = 'Could not connect to the store. Please try again.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> buy(ProductDetails product) async {
    if (!supportedPlatform ||
        !storeAvailable ||
        loading ||
        busy ||
        !products.any((p) => p.id == product.id)) {
      return;
    }
    pendingProductId = product.id;
    _notify();
    try {
      final started = await _nativeStore.buyConsumable(product);
      if (!started) {
        pendingProductId = null;
        _notice('The purchase could not be started. Please try again.');
      }
    } catch (error) {
      debugPrint(
        'MooseTime tips: purchase start failed (${error.runtimeType}).',
      );
      pendingProductId = null;
      _notice('Could not open the store purchase sheet. Please try again.');
    }
  }

  String _transactionKey(PurchaseDetails purchase) =>
      '${purchase.productID}:${purchase.purchaseID ?? purchase.transactionDate ?? identityHashCode(purchase)}';

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (!tipProductLabels.containsKey(purchase.productID)) return;
    debugPrint(
      'MooseTime tips: ${purchase.productID}: ${purchase.status.name}.',
    );
    if (purchase.status == PurchaseStatus.pending) {
      pendingProductId = purchase.productID;
      _notify();
      return;
    }
    final key = _transactionKey(purchase);
    _unfinished[key] = purchase;
    confirming = true;
    _notify();
    try {
      final successful =
          purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored;
      if (successful &&
          verifyPurchase != null &&
          !await verifyPurchase!(purchase)) {
        throw StateError('Purchase verification rejected');
      }
      if (purchase.pendingCompletePurchase) {
        await _nativeStore.completePurchase(purchase);
      }
      _unfinished.remove(key);
      pendingProductId = null;
      if (_processed.add(key)) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
            _notice('Thank you for supporting MooseTime!');
          case PurchaseStatus.restored:
            // Finish redelivered transactions; tips never grant entitlements.
            break;
          case PurchaseStatus.error:
            debugPrint(
              'MooseTime tips: purchase error (${purchase.error?.code ?? 'unknown'}).',
            );
            _notice(
              'The tip purchase failed. Please try again through the store.',
            );
          case PurchaseStatus.canceled:
            _notice('Tip purchase canceled.');
          case PurchaseStatus.pending:
            break;
        }
      }
    } catch (error) {
      debugPrint('MooseTime tips: confirmation failed (${error.runtimeType}).');
      _notice(
        'Could not confirm the tip with the store. Retry confirmation before making another purchase.',
      );
    } finally {
      confirming = false;
      _notify();
    }
  }

  Future<void> retryConfirmation() async {
    if (confirming || _disposed) return;
    // Serialize explicit retries with purchase stream updates.
    _updates = _updates.then((_) async {
      for (final purchase in _unfinished.values.toList()) {
        await _handlePurchase(purchase);
      }
    });
    await _updates;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
