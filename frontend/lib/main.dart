import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Replace with your real publishable key from Stripe Dashboard
    // Stripe Publishable Key
    Stripe.publishableKey = "pk_test_51TNlUFJcmJH1aFCdTVRkHgHsFumrYo7uizrKwpnZEiaOijdyfB7ZSCgxNL0tbdjdYi8B5QUR026FnUl3TvC39VpA008ZlPe9Ju";
    
    // Required for web to work correctly
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe Initialization Error: $e");
  }
  
  runApp(
    const ProviderScope(
      child: NotoApp(),
    ),
  );
}

