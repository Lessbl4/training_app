
import 'package:flutter/material.dart';
import 'package:training_app/widgets/custom_buttons.dart';

class EditModalTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaveEnabled;

  const EditModalTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.onSave,
    required this.onCancel,
    this.isSaveEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(179)),
            ),
          ),
        const SizedBox(height: 24.0),
        content,
        const SizedBox(height: 24.0),
        Row(
          children: [
            Expanded(
              child: CustomElevatedButton(
                text: 'Отмена',
                onPressed: onCancel,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: CustomElevatedButton(
                text: 'Сохранить',
                onPressed: isSaveEnabled ? onSave : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
