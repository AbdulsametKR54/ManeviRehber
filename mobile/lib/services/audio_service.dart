import 'package:just_audio/just_audio.dart';
import '../config/app_config.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  String get _baseUrl => AppConfig.baseUrl.replaceAll('/api', '');

  Future<void> playFromApi(String relativePath) async {
    try {
      final url = '$_baseUrl${relativePath.startsWith('/') ? '' : '/'}$relativePath';
      print('AudioService Playing: $url');
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('AudioService Play Error: $e');
    }
  }

  Future<void> playPlaylist(List<String> relativePaths) async {
    try {
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: relativePaths.map((path) {
          final url = '$_baseUrl${path.startsWith('/') ? '' : '/'}$path';
          return AudioSource.uri(Uri.parse(url));
        }).toList(),
      );
      print('AudioService Playing Playlist with ${relativePaths.length} items');
      await _player.stop();
      await _player.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
      await _player.play();
    } catch (e) {
      print('AudioService Playlist Error: $e');
    }
  }

  Future<void> playUrl(String url) async {
    try {
      print('AudioService Playing URL: $url');
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('AudioService Play URL Error: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  void dispose() {
    _player.dispose();
  }
}
