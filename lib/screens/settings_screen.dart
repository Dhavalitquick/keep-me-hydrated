import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/water_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final waterData = ref.watch(waterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Daily Water Goal'),
            subtitle: Text('${waterData.dailyGoal} ml'),
            trailing: const Icon(Icons.edit),
            onTap: () => _showSetGoalDialog(context, ref, waterData.dailyGoal),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded to drink water'),
            value: settings.notificationsEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).toggleNotifications(value),
          ),
          ListTile(
            title: const Text('Reminder Interval'),
            subtitle: Text('Every ${settings.reminderIntervalHours} hour(s)'),
            enabled: settings.notificationsEnabled,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showIntervalPicker(context, ref, settings.reminderIntervalHours),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).toggleDarkMode(value),
          ),
          const Divider(),
          ListTile(
            title: const Text('Reset Today\'s Progress'),
            textColor: Colors.red,
            leading: const Icon(Icons.refresh, color: Colors.red),
            onTap: () {
              ref.read(waterProvider.notifier).resetToday();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSetGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                ref.read(waterProvider.notifier).setDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, WidgetRef ref, int currentInterval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4, 6].map((hour) {
            return RadioListTile<int>(
              title: Text('Every $hour hour${hour > 1 ? 's' : ''}'),
              value: hour,
              groupValue: currentInterval,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setReminderInterval(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
