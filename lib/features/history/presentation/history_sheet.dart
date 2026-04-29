import 'package:flutter/material.dart';
import 'package:pomodoro/core/data/local/db_helper.dart';
import 'package:pomodoro/core/theme/app_colors.dart';

class HistorySheet extends StatefulWidget {
  final Future<List<PomodoroRecord>> Function() loadHistory;
  final Future<void> Function() clearHistory;

  const HistorySheet({
    super.key,
    required this.loadHistory,
    required this.clearHistory,
  });

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet> {
  late Future<List<PomodoroRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
              child: Row(
                children: [
                  Text(
                    'Session History',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _confirmClear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear all'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: c.divider, height: 1),

            // List
            Expanded(
              child: FutureBuilder<List<PomodoroRecord>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final records = snap.data ?? [];
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 48,
                              color: c.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'No sessions yet.\nGet to work.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: records.length,
                    separatorBuilder: (context2, index2) =>
                        Divider(color: c.divider, height: 1, indent: 16),
                    itemBuilder: (_, i) =>
                        _RecordTile(record: records[i], c: c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        final c = AppColors.of(context);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Clear History',
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'All recorded sessions will be permanently deleted.',
            style: TextStyle(color: c.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: TextStyle(color: Colors.red[400])),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await widget.clearHistory();
      setState(() => _future = widget.loadHistory());
    }
  }
}

class _RecordTile extends StatelessWidget {
  final PomodoroRecord record;
  final AppColors c;

  const _RecordTile({required this.record, required this.c});

  @override
  Widget build(BuildContext context) {
    final color = record.isWork ? AppAccent.work : AppAccent.breakColor;
    final label = record.isWork ? 'Work' : 'Break';
    final t = record.completedAt;
    final timeStr =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final dateStr = '${t.day}/${t.month}/${t.year}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          record.isWork ? Icons.timer_outlined : Icons.coffee_outlined,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        record.task?.isNotEmpty == true ? record.task! : label,
        style: TextStyle(
          color: c.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$label · ${record.durationMin} min · $dateStr $timeStr',
        style: TextStyle(color: c.textSecondary, fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${record.durationMin}m',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
