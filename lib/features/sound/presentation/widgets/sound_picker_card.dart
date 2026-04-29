import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'sound_btn.dart';

class SoundPickerCard extends StatelessWidget {
  final String? soundPath;
  final VoidCallback onPick;
  final VoidCallback onPreview;
  final VoidCallback onClear;

  const SoundPickerCard({
    super.key,
    required this.soundPath,
    required this.onPick,
    required this.onPreview,
    required this.onClear,
  });

  String get _fileName {
    if (soundPath == null) return 'No alert sound selected';
    return soundPath!.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasSound = soundPath != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSound
              ? AppAccent.work.withValues(alpha: 0.35)
              : c.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasSound ? Icons.music_note_rounded : Icons.music_off_rounded,
                color: hasSound ? AppAccent.work : c.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Alert Sound',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fileName,
            style: TextStyle(
              color: hasSound
                  ? c.textSecondary
                  : c.textSecondary.withValues(alpha: 0.5),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SoundBtn(
                  label: 'Browse',
                  icon: Icons.folder_open_outlined,
                  color: AppAccent.work,
                  onTap: onPick,
                ),
              ),
              if (hasSound) ...[
                const SizedBox(width: 8),
                SoundBtn(
                  label: 'Test',
                  icon: Icons.play_circle_outline,
                  color: AppAccent.breakColor,
                  onTap: onPreview,
                ),
                const SizedBox(width: 8),
                SoundBtn(
                  label: 'Remove',
                  icon: Icons.delete_outline,
                  color: c.textSecondary,
                  onTap: onClear,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
