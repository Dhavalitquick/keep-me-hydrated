import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/water_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(waterHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drink History'),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final dayData = history[index];
                final dateStr = DateFormat('EEE, MMM d, yyyy').format(dayData.date);
                final percent = (dayData.consumedAmount / dayData.dailyGoal * 100).toInt();

                return ListTile(
                  title: Text(dateStr),
                  subtitle: Text('${dayData.consumedAmount} / ${dayData.dailyGoal} ml'),
                  trailing: Text(
                    '$percent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: percent >= 100 ? Colors.green : Colors.blue,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
