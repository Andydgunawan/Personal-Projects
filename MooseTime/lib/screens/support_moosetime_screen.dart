import '../services/theme_service.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/in_app_purchase_service.dart';

class SupportMooseTimeScreen extends StatefulWidget {
  const SupportMooseTimeScreen({super.key, this.purchaseService});
  final InAppPurchaseService? purchaseService;

  @override
  State<SupportMooseTimeScreen> createState() => _SupportMooseTimeScreenState();
}

class _SupportMooseTimeScreenState extends State<SupportMooseTimeScreen> {
  late final InAppPurchaseService _service;
  late int _seenNotice;

  @override
  void initState() {
    super.initState();
    _service = widget.purchaseService ?? InAppPurchaseService.instance;
    _seenNotice = _service.noticeNumber;
    _service.addListener(_purchaseNotice);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_service.initialize());
    });
  }

  void _purchaseNotice() {
    if (!mounted || _seenNotice == _service.noticeNumber) return;
    _seenNotice = _service.noticeNumber;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_service.notice!)));
    });
  }

  @override
  void dispose() {
    _service.removeListener(_purchaseNotice);
    // The session service keeps listening so pending transactions can finish.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('Support MooseTime'),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF174529)
          : const Color(0xFF0A2B5A),
      foregroundColor: Colors.white,
    ),
    body: AnimatedBuilder(
      animation: _service,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "MooseTime is free to use. If the app has been useful to you and you'd like to support development and app-store costs, you can leave an optional tip below.\n\nTips are completely optional and do not unlock additional features.",
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: appColor(context, 0xFF0A2B5A),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Optional Tips',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: appColor(context, 0xFF0A2B5A),
            ),
          ),
          SizedBox(height: 16),
          if (!_service.supportedPlatform)
            Text(
              'Tips are currently unavailable on this device. Optional tips are available through the mobile App Store / Google Play version of MooseTime.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: appColor(context, 0xFF0A2B5A),
              ),
            )
          else ...[
            if (_service.loading) Center(child: CircularProgressIndicator()),
            if (_service.errorMessage != null) ...[
              Text(
                _service.errorMessage!,
                style: TextStyle(color: appColor(context, 0xFF0A2B5A)),
              ),
              TextButton.icon(
                onPressed: _service.loading ? null : _service.initialize,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),
            ],
            if (_service.products.isNotEmpty &&
                _service.missingProductIds.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Some tip options are not available yet.',
                  style: TextStyle(color: appColor(context, 0xFF0A2B5A)),
                ),
              ),
            for (final product in _service.products)
              Card(
                elevation: 0,
                color: appColor(context, 0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tipProductLabels[product.id]!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appColor(context, 0xFF0A2B5A),
                        ),
                      ),
                      if (product.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            product.title,
                            style: TextStyle(
                              color: appColor(context, 0xFF526780),
                            ),
                          ),
                        ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _service.busy || _service.loading
                            ? null
                            : () => _service.buy(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor(context, 0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Leave a tip ? ${product.price}'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_service.pendingProductId != null || _service.confirming)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Waiting for the store to confirm your tip...',
                  style: TextStyle(color: appColor(context, 0xFF0A2B5A)),
                ),
              ),
            if (_service.hasUnfinishedPurchases)
              TextButton(
                onPressed: _service.confirming
                    ? null
                    : _service.retryConfirmation,
                child: Text('Retry purchase confirmation'),
              ),
          ],
          SizedBox(height: 24),
          Text(
            'Thank you for using MooseTime, whether or not you choose to leave a tip.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: appColor(context, 0xFF0A2B5A),
            ),
          ),
        ],
      ),
    ),
  );
}
