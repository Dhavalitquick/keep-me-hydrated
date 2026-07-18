import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../providers/water_provider.dart';
import '../services/ad_helper.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(waterHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drink History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('No history yet'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final dayData = history[index];
                      final dateStr =
                          DateFormat('EEE, MMM d, yyyy').format(dayData.date);
                      final percent =
                          (dayData.consumedAmount / dayData.dailyGoal * 100)
                              .toInt();

                      return ListTile(
                        title: Text(dateStr),
                        subtitle: Text(
                            '${dayData.consumedAmount} / ${dayData.dailyGoal} ml'),
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
}
