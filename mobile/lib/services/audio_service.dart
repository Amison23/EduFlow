import 'package:audioplayers/audioplayers.dart';

/// Service for audio playback (voice narration)
class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  String? _currentAudioPath;

  bool get isPlaying => _isPlaying;
  String? get currentAudioPath => _currentAudioPath;

  AudioService() {
    _init();
  }

  void _init() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      
      if (state == PlayerState.completed) {
        _isPlaying = false;
        _currentAudioPath = null;
      }
    });
  }

  /// Play audio from URL
  Future<void> playFromUrl(String url) async {
    await _audioPlayer.play(UrlSource(url));
    _currentAudioPath = url;
  }

  /// Play audio from local file
  Future<void> playFromFile(String filePath) async {
    await _audioPlayer.play(DeviceFileSource(filePath));
    _currentAudioPath = filePath;
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentAudioPath = null;
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Get current position
  Future<Duration> getCurrentPosition() async {
    return _audioPlayer.getCurrentPosition() ?? Duration.zero;
  }

  /// Get total duration
  Future<Duration> getDuration() async {
    return _audioPlayer.getDuration() ?? Duration.zero;
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
