import 'package:pomodoro/core/result/api_result.dart';
import '../repositories/sound_repository.dart';

class PlaySoundUseCase {
  final SoundRepository _repository;
  const PlaySoundUseCase(this._repository);

  Future<ApiResult<void>> call(String path) => _repository.playSound(path);
}
