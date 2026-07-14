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
  bool _adShown = false;

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
    if (_adShown || _rewardedAd == null) {
      if (_rewardedAd == null) _loadRewardedAd();
      return;
    }

    final ad = _rewardedAd!;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _adShown = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _adShown = true;
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
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded to drink water'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              if (!value) {
                _showRewardedAdIfNeeded();
              }
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),
          ListTile(
            title: const Text('Reminder Interval'),
            subtitle: Text('Every ${settings.reminderIntervalHours} hour(s)'),
            enabled: settings.notificationsEnabled,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showIntervalPicker(context, ref, settings.reminderIntervalHours);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleDarkMode(value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Reset Today\'s Progress'),
            textColor: Colors.red,
            leading: const Icon(Icons.refresh, color: Colors.red),
            onTap: () {
              _showRewardedAdIfNeeded();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Manual Goal (ml)',
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: 16),
            const Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAgeGenderPicker(context, ref);
              },
              child: const Text('Calculate by Age & Gender'),
            ),
          ],
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

  void _showAgeGenderPicker(BuildContext context, WidgetRef ref) {
    String? selectedAgeGroup;
    String? selectedGender;

    final ageGroups = [
      '13–15 years',
      '16–18 years',
      '19–30 years',
      '31–50 years',
      '51–70 years',
      '71+ years',
    ];

    final Map<String, Map<String, int>> goals = {
      '13–15 years': {'Male': 2400, 'Female': 2100},
      '16–18 years': {'Male': 3300, 'Female': 2300},
      '19–30 years': {'Male': 3700, 'Female': 2700},
      '31–50 years': {'Male': 3700, 'Female': 2700},
      '51–70 years': {'Male': 3400, 'Female': 2500},
      '71+ years': {'Male': 3000, 'Female': 2300},
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Calculate Daily Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedAgeGroup,
                hint: const Text('Select Age Group'),
                items: ageGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedAgeGroup = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                hint: const Text('Select Gender'),
                items: ['Male', 'Female'].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedGender = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: (selectedAgeGroup != null && selectedGender != null)
                  ? () {
                      final goal = goals[selectedAgeGroup]![selectedGender]!;
                      ref.read(waterProvider.notifier).setDailyGoal(goal);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Calculate & Save'),
            ),
          ],
        ),
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
