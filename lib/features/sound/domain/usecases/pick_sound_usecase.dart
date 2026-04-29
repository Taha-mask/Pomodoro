import 'package:pomodoro/core/result/api_result.dart';
import '../repositories/sound_repository.dart';

class PickSoundUseCase {
  final SoundRepository _repository;
  const PickSoundUseCase(this._repository);

  Future<ApiResult<String?>> call() => _repository.pickSoundFile();
}
