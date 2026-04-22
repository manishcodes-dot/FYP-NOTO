import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

final paymentControllerProvider = Provider((ref) => PaymentController(ref));

class PaymentController {
  PaymentController(this.ref);
  final Ref ref;

  Future<bool> initPaymentSheet(String plan) async {
    if (kIsWeb) return true; // Skip initialization for web, we use confirmPayment directly
    try {
      final res = await ref.read(dioProvider).post('/payments/create-payment-intent', data: {'plan': plan});
      final clientSecret = res.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'NOTO Journal',
          style: ThemeMode.light,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Stripe Init Error: $e');
      return false;
    }
  }

  Future<void> confirmWebPayment(String plan) async {
    try {
      // 1. Create intent via backend
      final res = await ref.read(dioProvider).post('/payments/create-payment-intent', data: {'plan': plan});
      final clientSecret = res.data['clientSecret'];

      // 2. Confirm payment with Stripe's servers
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      debugPrint('Real Payment Successful for plan: $plan');
    } catch (e) {
      debugPrint('Web Payment Error: $e');
      if (e is DioException) {
        throw e.response?.data?['message'] ?? 'Backend error';
      }
      throw e.toString();
    }
  }

  Future<bool> subscribe(String plan) async {
    try {
      await ref.read(dioProvider).post('/payments/subscribe', data: {'plan': plan});
      await ref.read(authControllerProvider.notifier).fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }
}
