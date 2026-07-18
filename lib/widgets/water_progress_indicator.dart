import 'package:flutter/material.dart';
import 'package:wave/wave.dart';

class WaterProgressIndicator extends StatelessWidget {
  final int consumed;
  final int goal;

  const WaterProgressIndicator({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal);

    return Center(
      child: ClipOval(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [
                        Colors.lightBlueAccent.withAlpha(70),
                        Colors.blue,
                      ],
                      [
                        Colors.blue.shade300,
                        Colors.blue.shade700,
                      ],
                    ],
                    durations: const [35000, 20000],
                    heightPercentages: [
                      1 - progress,
                      (1 - progress) + 0.02,
                    ],
                    blur: const MaskFilter.blur(BlurStyle.solid, 2),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  backgroundColor: Colors.blue.shade50,
                  size: const Size(double.infinity, double.infinity),
                  waveAmplitude: 8,
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 5,
                  ),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "$consumed / $goal ml",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}