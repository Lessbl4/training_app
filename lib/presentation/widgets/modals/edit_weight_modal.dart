
import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/custom_ruler_picker.dart';
import 'package:training_app/presentation/widgets/modals/edit_modal_template.dart';

class EditWeightModal extends StatefulWidget {
  final double initialValue;
  final Function(double) onSave;

  const EditWeightModal({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  @override
  EditWeightModalState createState() => EditWeightModalState();
}

class EditWeightModalState extends State<EditWeightModal> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return EditModalTemplate(
      title: 'Изменить вес',
      content: CustomRulerPicker(
        min: 30,
        max: 250,
        unit: 'kg',
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
