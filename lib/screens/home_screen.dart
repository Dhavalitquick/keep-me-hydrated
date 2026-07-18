import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../providers/water_provider.dart';
import '../services/ad_helper.dart';
import '../widgets/water_progress_indicator.dart';
import '../widgets/quick_add_buttons.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int _quickAddClickCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("Banner failed: ${err.code}, ${err.message}");
          ad.dispose();
        },
      ),
    ).load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {}
          );
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd failed to load: $err');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('Interstitial ad is not ready yet.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
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
                  QuickAddButtons(
                    callAds: () {
                      _quickAddClickCount++;
                      // Randomly choose a target between 3 and 5
                      int target = 3 + Random().nextInt(3); 
                      if (_quickAddClickCount >= target) {
                        showInterstitialAd();
                        _quickAddClickCount = 0;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCustomAmountDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Custom Amount of ml'),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Today\'s Logs',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                          leading:
                              const Icon(Icons.water_drop, color: Colors.blue),
                          title: Text(
                            '${log.amount} ml${log.label != null && log.label!.isNotEmpty ? ' (${log.label})' : ''}',
                          ),
                          subtitle:
                              Text(DateFormat('hh:mm a').format(log.timestamp)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => ref
                                .read(waterProvider.notifier)
                                .removeLog(log.id),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: color.withAlpha(15),
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
                ref
                    .read(waterProvider.notifier)
                    .addWater(amount, label: labelController.text.trim());
                Navigator.pop(context);
                showInterstitialAd();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
