import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moose_time/services/in_app_purchase_service.dart';
import 'package:moose_time/screens/support_moosetime_screen.dart';

final tip = ProductDetails(
  id: 'moosetime_tip_099',
  title: 'Small Tip',
  description: 'Optional support',
  price: '?0.99',
  rawPrice: 0.99,
  currencyCode: 'EUR',
);

class FakeTipStore implements TipStore {
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  int listeners = 0;
  int availabilityCalls = 0;
  int buys = 0;
  int completions = 0;
  bool available = true;
  bool failCompletion = false;
  bool failQuery = false;
  @override
  Stream<List<PurchaseDetails>> get purchaseStream {
    listeners++;
    return updates.stream;
  }

  @override
  Future<bool> isAvailable() async {
    availabilityCalls++;
    return available;
  }

  @override
  Future<ProductDetailsResponse> queryProducts(Set<String> ids) async {
    if (failQuery) throw Exception('Store offline');
    return ProductDetailsResponse(
      productDetails: [tip],
      notFoundIDs: ids.where((id) => id != tip.id).toList(),
    );
  }

  @override
  Future<bool> buyConsumable(ProductDetails product) async {
    buys++;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completions++;
    if (failCompletion) throw Exception('Confirmation failed');
  }
}

PurchaseDetails event(PurchaseStatus status, String id) =>
    PurchaseDetails(
        productID: tip.id,
        purchaseID: id,
        transactionDate: '1000',
        status: status,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
      )
      ..pendingCompletePurchase =
          status == PurchaseStatus.purchased ||
          status == PurchaseStatus.restored;

Future<void> flushUpdates() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Windows never calls native stores', () async {
    final store = FakeTipStore();
    final service = InAppPurchaseService(
      store: store,
      supportedPlatformOverride: false,
    );
    await service.initialize();
    expect(store.availabilityCalls, 0);
    expect(store.listeners, 0);
    service.dispose();
    await store.updates.close();
  });

  test('Missing products, unavailable stores and query failures recover with manual retry', () async {
    final store = FakeTipStore()..available = false;
    final service = InAppPurchaseService(
      store: store,
      supportedPlatformOverride: true,
    );
    await service.initialize();
    expect(service.storeAvailable, isFalse);
    store.available = true;
    store.failQuery = true;
    await service.initialize();
    expect(service.errorMessage, isNotNull);
    store.failQuery = false;
    await service.initialize();
    expect(service.products.single.price, '?0.99');
    expect(service.missingProductIds.length, 3);
    expect(store.listeners, 1);
    service.dispose();
    await store.updates.close();
  });

  test('Consumable success completes before thanks; repeated tips and completion retries are safe', () async {
    final store = FakeTipStore();
    final service = InAppPurchaseService(
      store: store,
      supportedPlatformOverride: true,
    );
    await service.initialize();
    await service.buy(tip);
    await service.buy(tip);
    expect(store.buys, 1);
    store.updates.add([event(PurchaseStatus.pending, 'one')]);
    await flushUpdates();
    expect(service.busy, isTrue);
    store.failCompletion = true;
    store.updates.add([event(PurchaseStatus.purchased, 'one')]);
    await flushUpdates();
    expect(service.notice, isNot(contains('Thank you')));
    expect(service.hasUnfinishedPurchases, isTrue);
    await service.buy(tip);
    expect(store.buys, 1);
    store.failCompletion = false;
    await service.retryConfirmation();
    expect(service.notice, 'Thank you for supporting MooseTime!');
    expect(service.busy, isFalse);
    final notices = service.noticeNumber;
    store.updates.add([event(PurchaseStatus.purchased, 'one')]);
    await flushUpdates();
    expect(service.noticeNumber, notices);
    await service.buy(tip);
    expect(store.buys, 2);
    store.updates.add([event(PurchaseStatus.purchased, 'two')]);
    await flushUpdates();
    expect(service.noticeNumber, notices + 1);
    service.dispose();
    await store.updates.close();
  });

  test(
    'Restored, error and canceled events never show a success message',
    () async {
      final store = FakeTipStore();
      final service = InAppPurchaseService(
        store: store,
        supportedPlatformOverride: true,
      );
      await service.initialize();
      store.updates.add([event(PurchaseStatus.restored, 'restored')]);
      await flushUpdates();
      expect(store.completions, 1);
      expect(service.notice, isNull);
      for (final status in [PurchaseStatus.error, PurchaseStatus.canceled]) {
        store.updates.add([event(status, status.name)]);
        await flushUpdates();
        expect(service.notice, isNot(contains('Thank you')));
        expect(service.busy, isFalse);
      }
      service.dispose();
      await store.updates.close();
    },
  );

  testWidgets(
    'Support shows store-localized prices and desktop availability without restore button',
    (tester) async {
      final store = FakeTipStore();
      final service = InAppPurchaseService(
        store: store,
        supportedPlatformOverride: true,
      );
      await tester.pumpWidget(
        MaterialApp(home: SupportMooseTimeScreen(purchaseService: service)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Leave a tip ? ?0.99'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      expect(store.updates.hasListener, isTrue);
      service.dispose();
      await store.updates.close();
      final desktop = InAppPurchaseService(supportedPlatformOverride: false);
      await tester.pumpWidget(
        MaterialApp(home: SupportMooseTimeScreen(purchaseService: desktop)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('mobile App Store / Google Play'),
        findsOneWidget,
      );
      expect(find.byType(ElevatedButton), findsNothing);
      await tester.pumpWidget(const SizedBox());
      desktop.dispose();
    },
  );
}
