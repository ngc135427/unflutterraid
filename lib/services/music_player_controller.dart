import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'unraid_api_client.dart';

/// App-scoped audio playback so music continues across routes with a mini bar.
class MusicPlayerController extends ChangeNotifier {
  MusicPlayerController._();

  static final MusicPlayerController instance = MusicPlayerController._();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _eventSub;
  bool _bound = false;

  UnraidApiClient? _apiClient;
  List<UnraidFileEntry> _queue = const [];
  int _index = 0;
  bool _loading = false;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _fullPlayerOpen = false;

  UnraidApiClient? get apiClient => _apiClient;
  List<UnraidFileEntry> get queue => _queue;
  int get index => _index;
  bool get loading => _loading;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get playing => _playing;
  bool get hasSession => _queue.isNotEmpty && _apiClient != null;
  bool get showMiniBar => hasSession && !_fullPlayerOpen;

  void setFullPlayerOpen(bool open) {
    if (_fullPlayerOpen == open) {
      return;
    }
    _fullPlayerOpen = open;
    notifyListeners();
  }

  UnraidFileEntry? get track {
    if (_queue.isEmpty || _index < 0 || _index >= _queue.length) {
      return null;
    }
    return _queue[_index];
  }

  double get progress {
    if (_duration.inMilliseconds <= 0) {
      return 0;
    }
    return (_position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  void _ensureBound() {
    if (_bound) {
      return;
    }
    _bound = true;
    _positionSub = _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (duration == null) {
        return;
      }
      _duration = duration;
      notifyListeners();
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      _playing = state.playing;
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        unawaited(skipNext(autoFromCompletion: true));
      }
    });
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        _loading = false;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> playQueue({
    required UnraidApiClient apiClient,
    required List<UnraidFileEntry> queue,
    required int initialIndex,
  }) async {
    if (queue.isEmpty) {
      return;
    }
    _ensureBound();
    _apiClient = apiClient;
    _queue = List<UnraidFileEntry>.from(queue);
    _index = initialIndex.clamp(0, _queue.length - 1);
    await _loadCurrent(autoplay: true);
  }

  Future<void> _loadCurrent({required bool autoplay}) async {
    final client = _apiClient;
    final current = track;
    if (client == null || current == null) {
      return;
    }
    _loading = true;
    _error = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
    try {
      final uri = client.fileManager.rawUri(current.path);
      await _player.setAudioSource(AudioSource.uri(uri));
      _loading = false;
      _duration = _player.duration ?? Duration.zero;
      notifyListeners();
      if (autoplay) {
        await _player.play();
      }
    } catch (error) {
      _loading = false;
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_loading || _error != null || !hasSession) {
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekFraction(double value) async {
    if (_duration.inMilliseconds <= 0) {
      return;
    }
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _player.seek(position);
  }

  Future<bool> skipPrevious() async {
    if (_index <= 0) {
      return false;
    }
    _index -= 1;
    await _loadCurrent(autoplay: true);
    return true;
  }

  Future<bool> skipNext({bool autoFromCompletion = false}) async {
    if (_index + 1 >= _queue.length) {
      if (autoFromCompletion) {
        await _player.seek(Duration.zero);
        await _player.pause();
      }
      return false;
    }
    _index += 1;
    await _loadCurrent(autoplay: true);
    return true;
  }

  Future<void> stopAndClear() async {
    await _player.stop();
    _queue = const [];
    _index = 0;
    _apiClient = null;
    _loading = false;
    _error = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _playing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Singleton kept for app life; dispose only if ever torn down in tests.
    unawaited(_playerStateSub?.cancel() ?? Future<void>.value());
    unawaited(_positionSub?.cancel() ?? Future<void>.value());
    unawaited(_durationSub?.cancel() ?? Future<void>.value());
    unawaited(_eventSub?.cancel() ?? Future<void>.value());
    unawaited(_player.dispose());
    super.dispose();
  }
}
