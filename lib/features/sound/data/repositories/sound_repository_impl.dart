import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomodoro/core/result/api_result.dart';
import '../../domain/repositories/sound_repository.dart';

class SoundRepositoryImpl implements SoundRepository {
  final AudioPlayer _player;
  const SoundRepositoryImpl(this._player);

  @override
  Future<ApiResult<String?>> pickSoundFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'aac', 'm4a', 'flac'],
        withData: Platform.isAndroid || Platform.isIOS,
      );
      if (result == null) return const ApiSuccess(null);

      final file = result.files.single;
      if (file.path != null) return ApiSuccess(file.path);

      if (file.bytes != null && file.name.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final dest = File(p.join(dir.path, 'sounds', file.name));
        await dest.parent.create(recursive: true);
        await dest.writeAsBytes(file.bytes!);
        return ApiSuccess(dest.path);
      }

      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to pick file: $e');
    }
  }

  @override
  Future<ApiResult<void>> playSound(String path) async {
    try {
      if (!await File(path).exists()) return const ApiError('File not found');
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to play sound: $e');
    }
  }

  @override
  Future<void> stopSound() => _player.stop();
}
