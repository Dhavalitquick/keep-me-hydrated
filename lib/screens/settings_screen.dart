import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/settings_provider.dart';
import '../providers/water_provider.dart';
import '../services/ad_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('RewardedAd failed to load: $err');
        },
      ),
    );
  }

  void _showRewardedAdIfNeeded() {
    if (_rewardedAd == null) {
      _loadRewardedAd();
      return;
    }

    final ad = _rewardedAd!;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        // Reward callback
      },
    );

    _rewardedAd = null;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () {
              _showSetGoalDialog(context, ref, waterData.dailyGoal);
              _showRewardedAdIfNeeded();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded to drink water'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
              _showRewardedAdIfNeeded();
            },
          ),
          ListTile(
            title: const Text('Reminder Interval'),
            subtitle: Text('Every ${settings.reminderIntervalHours} hour(s)'),
            enabled: settings.notificationsEnabled,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showIntervalPicker(context, ref, settings.reminderIntervalHours);
              _showRewardedAdIfNeeded();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleDarkMode(value);
              _showRewardedAdIfNeeded();
            },
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
              _showRewardedAdIfNeeded();
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
