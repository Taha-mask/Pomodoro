import 'package:pomodoro/core/result/api_result.dart';

abstract interface class SoundRepository {
  Future<ApiResult<String?>> pickSoundFile();
  Future<ApiResult<void>> playSound(String path);
  Future<void> stopSound();
}
