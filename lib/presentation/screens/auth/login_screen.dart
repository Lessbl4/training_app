
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/presentation/widgets/custom_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSwitchMode});
  final VoidCallback onSwitchMode;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool hide1 = true;
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
    });

    if (_email.text.isEmpty || _pass.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const CustomErrorDialog(message: "Заполните все поля"),
      );
      setState(() {
        loading = false;
      });
      return;
    }

    String? res;
    try {
      await _auth.signInWithEmailAndPassword(
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

    Navigator.of(context).pop();
  }

  Future<void> resetPassword() async {
    if (_email.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const CustomErrorDialog(message: "Введите email для сброса пароля"),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    String? result;
    try {
      await _auth.sendPasswordResetEmail(email: _email.text.trim());
    } on FirebaseAuthException catch (e) {
      result = e.message;
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (result != null) {
      showDialog(
        context: context,
        builder: (context) => CustomErrorDialog(message: result ?? 'An unknown error occurred'),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Письмо для сброса пароля отправлено",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
        ),
      );
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resetPassword,
                        child: const Text("Забыли пароль?"),
                      ),
                    ),
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
                                "Войти",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('У вас еще нет аккаунта?'),
                        TextButton(
                          onPressed: widget.onSwitchMode,
                          child: const Text('Создать'),
                        ),
                      ],
                    )
                  ],
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
