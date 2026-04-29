import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'step_button.dart';

class MinutePicker extends StatelessWidget {
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool enabled;

  const MinutePicker({
    super.key,
    required this.label,
    required this.minutes,
    required this.onChanged,
    required this.color,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StepButton(
                icon: Icons.remove,
                onTap: enabled && minutes > 1 ? () => onChanged(minutes - 1) : null,
                color: color,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: enabled ? () => _showInputDialog(context, c) : null,
                child: Container(
                  width: 86,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$minutes min',
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              StepButton(
                icon: Icons.add,
                onTap: enabled && minutes < 120 ? () => onChanged(minutes + 1) : null,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context, AppColors c) {
    showDialog(
      context: context,
      builder: (_) => _MinuteInputDialog(
        label: label,
        minutes: minutes,
        color: color,
        onChanged: onChanged,
        c: c,
      ),
    );
  }
}

class _MinuteInputDialog extends StatefulWidget {
  final String label;
  final int minutes;
  final Color color;
  final ValueChanged<int> onChanged;
  final AppColors c;

  const _MinuteInputDialog({
    required this.label,
    required this.minutes,
    required this.color,
    required this.onChanged,
    required this.c,
  });

  @override
  State<_MinuteInputDialog> createState() => _MinuteInputDialogState();
}

class _MinuteInputDialogState extends State<_MinuteInputDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.minutes}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.label,
        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: widget.color,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          suffixText: 'min',
          suffixStyle: TextStyle(color: widget.color.withValues(alpha: 0.6)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: c.divider),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.color, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            final v = int.tryParse(_ctrl.text) ?? widget.minutes;
            widget.onChanged(v.clamp(1, 120));
            Navigator.pop(context);
          },
          child: Text('OK', style: TextStyle(color: widget.color)),
        ),
      ],
    );
  }
}
