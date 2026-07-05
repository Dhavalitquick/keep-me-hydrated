import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playWaterSound() async {
    try {
      await _player.play(AssetSource('sound/drink_water.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
