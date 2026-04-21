import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../presentation/screens/onboarding/onboarding_container.dart';

import 'package:training_app/widgets/animated_scale_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  final _auth = AuthService();

  bool hide1 = true;
  bool hide2 = true;
  bool loading = false;
  String error = "";

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      error = "";
      loading = true;
    });

    if (_email.text.isEmpty || _pass.text.isEmpty) {
      setState(() {
        error = "Заполни все поля";
        loading = false;
      });
      return;
    }

    if (_pass.text != _confirm.text) {
      setState(() {
        error = "Пароли не совпадают";
        loading = false;
      });
      return;
    }

    String p = _pass.text;
    bool hasUpper = p.contains(RegExp(r'[A-Z]'));
    bool hasDigits = p.contains(RegExp(r'[0-9]'));
    bool hasSpecial = p.contains(RegExp(r'[!@#\$%^&*(),.?\":{}|<>]'));
    if (p.length < 8 || !hasUpper || !hasDigits || !hasSpecial) {
      setState(() {
        error =
            "Пароль должен быть от 8 символов и содержать:\n• заглавную букву\n• цифру\n• спецсимвол (!@#\$%^&*)";
        loading = false;
      });
      return;
    }

    String? res = await _auth.register(_email.text.trim(), _pass.text.trim());

    if (!mounted) return;

    if (res != null) {
      setState(() {
        error = res;
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
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (_) => const OnboardingContainer(),
        ),
      );
    }
  }

  Widget field(String hint, TextEditingController c,
      {bool obscure = false, VoidCallback? toggle}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                field("Email", _email),
                field("Пароль", _pass,
                    obscure: hide1, toggle: () => setState(() => hide1 = !hide1)),
                field("Повтори пароль", _confirm,
                    obscure: hide2, toggle: () => setState(() => hide2 = !hide2)),
                AnimatedOpacity(
                  opacity: error.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
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
                          onPressed: submit,
                          child: const ElevatedButton(
                            onPressed: null,
                            child: Text("Создать аккаунт"),
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
