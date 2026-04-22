import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../../app/routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool isLoading = false;

  Future<void> _onSubscribe(String plan) async {
    if (kIsWeb) {
      _showWebPaymentDialog(plan);
      return;
    }
    setState(() => isLoading = true);

    final initialized = await ref
        .read(paymentControllerProvider)
        .initPaymentSheet(plan);

    if (initialized) {
      try {
        await Stripe.instance.presentPaymentSheet();

        // After successful payment, update our DB
        final success = await ref
            .read(paymentControllerProvider)
            .subscribe(plan);
        if (success && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Welcome to Pro!')));
          Navigator.pop(context);
        }
      } on StripeException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Cancelled: ${e.error.localizedMessage}'),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize payment.')),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showWebPaymentDialog(String plan) {
    bool isPaymentSuccess = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isPaymentSuccess ? 'Payment Successful!' : 'Pay for $plan'),
          content: SizedBox(
            width: 500,
            child: isPaymentSuccess
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 64),
                      const SizedBox(height: 16),
                      Text('Congratulations! You have successfully upgraded to the $plan plan. You now have full access to all AI features.'),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enter your card details:'),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: CardField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            if (!isPaymentSuccess)
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (isPaymentSuccess) {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushNamedAndRemoveUntil(this.context, AppRoutes.home, (route) => false);
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      try {
                        await ref.read(paymentControllerProvider).confirmWebPayment(plan);
                        await ref.read(paymentControllerProvider).subscribe(plan);
                        
                        if (mounted) {
                          setDialogState(() {
                            isLoading = false;
                            isPaymentSuccess = true;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isPaymentSuccess ? 'Done' : 'Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to NOTO Pro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock AI Chatbot',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get unlimited access to AI structured note generation, summaries, and personalized assistants.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            if (isPremium)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    const Text(
                      'You are currently a Pro member!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else ...[
              _buildPlanCard(
                title: 'Monthly Pro',
                price: '\$4.99/mo',
                description: 'Billed monthly. Cancel anytime.',
                onTap: isLoading ? null : () => _onSubscribe('monthly'),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                title: 'Yearly Pro',
                price: '\$39.99/yr',
                description: 'Save 33%. Billed annually.',
                isPopular: true,
                onTap: isLoading ? null : () => _onSubscribe('yearly'),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Safe & Secure Payment',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required VoidCallback? onTap,
    bool isPopular = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular ? AppColors.primary : Colors.grey[300]!,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isPopular
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
