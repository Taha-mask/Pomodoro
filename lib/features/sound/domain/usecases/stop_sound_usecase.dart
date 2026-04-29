import '../repositories/sound_repository.dart';

class StopSoundUseCase {
  final SoundRepository _repository;
  const StopSoundUseCase(this._repository);

  Future<void> call() => _repository.stopSound();
}
