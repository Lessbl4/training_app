import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Пути к звукам
  static const String click = 'sounds/click.mp3';
  static const String save = 'sounds/save.mp3';
  static const String notify = 'sounds/notify.mp3';
  static const String finish = 'sounds/finish.mp3';

  static Future<void> play(String path) async {
    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      // Sound playback is not critical
    }
  }

  static Future<void> playClick() => play(click);
  static Future<void> playSave() => play(save);
  static Future<void> playNotify() => play(notify);
  static Future<void> playFinish() => play(finish);
  static Future<void> playTick() => play("sounds/tick.mp3");
}
