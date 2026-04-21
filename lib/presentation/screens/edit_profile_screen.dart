import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialValue;
  final String fieldKey;

  const EditProfileScreen({super.key, required this.initialValue, required this.fieldKey});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        widget.fieldKey: _controller.text,
      });
      if (mounted) {
        SoundService.playSave();
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка сохранения: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Изменить данные";
    if (widget.fieldKey == 'name') title = "Изменить имя";
    if (widget.fieldKey == 'weight') title = "Изменить вес";
    if (widget.fieldKey == 'height') title = "Изменить рост";
    if (widget.fieldKey == 'experience') title = "Изменить стаж";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
        body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: widget.fieldKey == "weight" || widget.fieldKey == "height" || widget.fieldKey == "experience"
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: title,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CupertinoActivityIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () {
                        SoundService.playClick();
                        _saveProfileData();
                      },
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueAccent,
                      child: const Text("Сохранить"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
