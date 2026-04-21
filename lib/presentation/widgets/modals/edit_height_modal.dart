
import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/custom_ruler_picker.dart';
import 'package:training_app/presentation/widgets/modals/edit_modal_template.dart';

class EditHeightModal extends StatefulWidget {
  final double initialValue;
  final Function(double) onSave;

  const EditHeightModal({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  @override
  EditHeightModalState createState() => EditHeightModalState();
}

class EditHeightModalState extends State<EditHeightModal> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return EditModalTemplate(
      title: 'Изменить рост',
      content: CustomRulerPicker(
        min: 100,
        max: 250,
        unit: 'cm',
        value: _value,
        onChanged: (value) => setState(() => _value = value),
      ),
      onSave: () {
        widget.onSave(_value);
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
    );
  }
}
