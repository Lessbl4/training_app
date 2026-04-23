
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/presentation/widgets/custom_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onSwitchMode});
  final VoidCallback onSwitchMode;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool hide1 = true;
  bool hide2 = true;
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
    });

    if (_email.text.isEmpty || _pass.text.isEmpty || _confirm.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const CustomErrorDialog(message: "Заполните все поля"),
      );
      setState(() {
        loading = false;
      });
      return;
    }

    if (_pass.text != _confirm.text) {
      showDialog(
        context: context,
        builder: (context) => const CustomErrorDialog(message: "Пароли не совпадают"),
      );
      setState(() {
        loading = false;
      });
      return;
    }

    String p = _pass.text;
    bool hasUpper = p.contains(RegExp(r'[A-Z]'));
    bool hasDigits = p.contains(RegExp(r'[0-9]'));
    bool hasSpecial = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    if (p.length < 8 || !hasUpper || !hasDigits || !hasSpecial) {
      showDialog(
        context: context,
        builder: (context) => const CustomErrorDialog(message: "Пароль должен быть от 8 символов и содержать:\n• заглавную букву\n• цифру\n• спецсимвол (!@#\$%^&*)"),
      );
      setState(() {
        loading = false;
      });
      return;
    }

    String? res;
    try {
      await _auth.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _pass.text.trim());
    } on FirebaseAuthException catch (e) {
      res = e.message;
    }

    if (!mounted) return;

    if (res != null) {
      showDialog(
        context: context,
        builder: (context) => CustomErrorDialog(message: res ?? 'An unknown error occurred'),
      );
      setState(() {
        loading = false;
      });
      return;
    }


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Аккаунт успешно создан"),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSwitchMode();
    }
  }

  Widget field(String hint, TextEditingController c,
      {bool obscure = false, VoidCallback? toggle}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.05),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        suffixIcon: toggle != null
            ? IconButton(
                onPressed: toggle,
                icon: Icon(
                  obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: Colors.white54,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'auth_logo',
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.flame_fill,
                          size: 80,
                          color: theme.colorScheme.primary,
                          shadows: [
                            Shadow(
                              color: Colors.blueAccent.withOpacity(0.8),
                              blurRadius: 20,
                            ),
                          ],
                        )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scaleXY(begin: 1.0, end: 1.05, duration: 1.5.seconds),
                        const SizedBox(width: 10),
                        const Text(
                          'GYMIFY',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    field("Email", _email),
                    const SizedBox(height: 20),
                    field("Пароль", _pass,
                        obscure: hide1, toggle: () => setState(() => hide1 = !hide1)),
                    const SizedBox(height: 20),
                    field("Повторите пароль", _confirm,
                        obscure: hide2, toggle: () => setState(() => hide2 = !hide2)),
                    const SizedBox(height: 20),
                    loading
                        ? const CupertinoActivityIndicator()
                        : Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blueAccent, Colors.cyan],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(68, 138, 255, 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              ),
                              child: const Text(
                                "Создать аккаунт",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Уже есть аккаунт?'),
                        TextButton(
                          onPressed: widget.onSwitchMode,
                          child: const Text('Войти'),
                        ),
                      ],
                    )
                  ],
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
