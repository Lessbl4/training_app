import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/presentation/widgets/custom_error_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
Navigator.of(context).pop();
    }
  }



  Widget field(String hint, TextEditingController c,
      {bool obscure = false, VoidCallback? toggle}) {
    final theme = Theme.of(context);

    return TextField(
      controller: c,
      obscureText: obscure,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(128),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: toggle != null
            ? IconButton(
                onPressed: toggle,
                icon: Icon(
                  obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: theme.colorScheme.onSurface.withAlpha(178),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal),
          child: Column(
            children: [
              Hero(
                tag: 'logo',
                child: Icon(
                  CupertinoIcons.flame_fill,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
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
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: submit,
                        child: const Text("Создать аккаунт"),
                      ),
                    ),

            ],
          ),
        ),
      ),
    );
  }
}
