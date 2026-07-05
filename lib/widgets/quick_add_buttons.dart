import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/water_provider.dart';

class QuickAddButtons extends ConsumerWidget {
  const QuickAddButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAddButton(ref, 100),
        _buildAddButton(ref, 250),
        _buildAddButton(ref, 500),
      ],
    );
  }

  Widget _buildAddButton(WidgetRef ref, int amount) {
    String label = '';
    if (amount == 100) label = 'Small Cup';
    if (amount == 250) label = 'Glass';
    if (amount == 500) label = 'Bottle';

    return ElevatedButton(
      onPressed: () => ref.read(waterProvider.notifier).addWater(amount, label: label),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Text('+$amount\nml', textAlign: TextAlign.center),
    );
  }
}
