import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/water_provider.dart';
import '../services/notification_service.dart';
import '../widgets/water_progress_indicator.dart';
import '../widgets/quick_add_buttons.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(waterProvider.notifier).checkAndResetDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final waterData = ref.watch(waterProvider);
    final remaining = waterData.dailyGoal - waterData.consumedAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keep Me Hydrated'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            WaterProgressIndicator(
              consumed: waterData.consumedAmount,
              goal: waterData.dailyGoal,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(
                  context,
                  'Goal',
                  '${waterData.dailyGoal} ml',
                  Icons.flag_rounded,
                  Colors.blue,
                ),
                _buildInfoCard(
                  context,
                  'Remaining',
                  '${remaining < 0 ? 0 : remaining} ml',
                  Icons.hourglass_empty_rounded,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const QuickAddButtons(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddCustomAmountDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Amount'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Today\'s Logs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            if (waterData.logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No water added yet today'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: waterData.logs.length,
                itemBuilder: (context, index) {
                  final log = waterData.logs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.water_drop, color: Colors.blue),
                    title: Text('${log.amount} ml${log.label != null && log.label!.isNotEmpty ? ' (${log.label})' : ''}'),
                    subtitle: Text(DateFormat('hh:mm a').format(log.timestamp)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => ref.read(waterProvider.notifier).removeLog(log.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomAmountDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final labelController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 200',
                suffixText: 'ml',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Label (Optional)',
                hintText: 'e.g. Glass, Bottle',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                ref.read(waterProvider.notifier).addWater(
                      amount,
                      label: labelController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
