import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/main_navigation.dart';
import 'package:training_app/widgets/animated_scale_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _exp = TextEditingController();

  bool loading = false;
  String error = "";

  late AnimationController _scale;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim =
        CurvedAnimation(parent: _scale, curve: Curves.easeOutBack);
    _scale.forward();
  }

  @override
  void dispose() {
    _scale.dispose();
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _exp.dispose();
    super.dispose();
  }

  Widget field(String hint, TextEditingController c,
      {bool isNumber = false}) {
    return Container(
      height: 55,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        controller: c,
        placeholder: hint,
        placeholderStyle: const TextStyle(color: Colors.grey),
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  Future<void> save() async {
    if (_name.text.trim().isEmpty ||
        _weight.text.trim().isEmpty ||
        _height.text.trim().isEmpty ||
        _exp.text.trim().isEmpty) {
      setState(() => error = "Заполни все поля");
      return;
    }

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": _name.text.trim(),
        "weight": _weight.text.trim(),
        "height": _height.text.trim(),
        "experience": _exp.text.trim(),
        "photo": "",
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = "Ошибка сохранения. Попробуй снова.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Hero(
                    tag: 'logo',
                    child: Icon(CupertinoIcons.flame_fill,
                        size: 70, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                const Text(
                  "GYMIFY",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Расскажи о себе",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                field("Имя", _name),
                field("Вес (кг)", _weight, isNumber: true),
                field("Рост (см)", _height, isNumber: true),
                field("Стаж тренировок (лет)", _exp, isNumber: true),

                AnimatedOpacity(
                  opacity: error.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                loading
                    ? const CupertinoActivityIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: AnimatedScaleButton(
                          onPressed: save,
                          child: const CupertinoButton(
                            color: Colors.blueAccent,
                            onPressed: null,
                            child: Text("Продолжить"),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
