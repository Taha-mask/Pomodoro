import 'package:audioplayers/audioplayers.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro/core/data/local/db_helper.dart';
import 'package:pomodoro/features/sound/data/repositories/sound_repository_impl.dart';
import 'package:pomodoro/features/sound/domain/repositories/sound_repository.dart';
import 'package:pomodoro/features/sound/domain/usecases/pick_sound_usecase.dart';
import 'package:pomodoro/features/sound/domain/usecases/play_sound_usecase.dart';
import 'package:pomodoro/features/sound/domain/usecases/stop_sound_usecase.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<DbHelper>(() => DbHelper());

  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  sl.registerLazySingleton<SoundRepository>(
    () => SoundRepositoryImpl(sl<AudioPlayer>()),
  );

  sl.registerLazySingleton(() => PickSoundUseCase(sl<SoundRepository>()));
  sl.registerLazySingleton(() => PlaySoundUseCase(sl<SoundRepository>()));
  sl.registerLazySingleton(() => StopSoundUseCase(sl<SoundRepository>()));

  sl.registerFactory(
    () => TimerCubit(
      pickSound: sl<PickSoundUseCase>(),
      playSound: sl<PlaySoundUseCase>(),
      stopSound: sl<StopSoundUseCase>(),
      db: sl<DbHelper>(),
    ),
  );
}
