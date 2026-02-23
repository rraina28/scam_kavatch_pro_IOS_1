import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_manager.dart';

class PremiumAdGate extends StatelessWidget {

  final Widget child;

  const PremiumAdGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    final premium = context.watch<PremiumManager>();

    // Premium users NEVER see ads
    if (premium.isPremium) {
      return const SizedBox.shrink();
    }

    return child;
  }
}