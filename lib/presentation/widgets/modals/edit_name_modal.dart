
import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/modals/edit_modal_template.dart';

class EditNameModal extends StatefulWidget {
  final String initialValue;
  final Function(String) onSave;

  const EditNameModal({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  @override
  EditNameModalState createState() => EditNameModalState();
}

class EditNameModalState extends State<EditNameModal> {
  late TextEditingController _controller;
  bool _isSaveEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _isSaveEnabled = _controller.text.isNotEmpty;
    _controller.addListener(() {
      setState(() {
        _isSaveEnabled = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EditModalTemplate(
      title: 'Изменить имя',
      content: TextFormField(
        controller: _controller,
        autofocus: true,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.colorScheme.surface.withAlpha(128),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      onSave: () {
        widget.onSave(_controller.text);
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
      isSaveEnabled: _isSaveEnabled,
    );
  }
}
