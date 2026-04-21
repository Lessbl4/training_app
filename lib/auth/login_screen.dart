import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/main_navigation.dart';
import 'auth_service.dart';
import 'package:training_app/widgets/animated_scale_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final _auth = AuthService();

  bool hide1 = true;
  bool loading = false;
  String error = "";

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
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

    String? res = await _auth.login(_email.text.trim(), _pass.text.trim());

    if (!mounted) return;

    if (res != null) {
      setState(() {
        error = res;
        loading = false;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => const MainNavigation(),
      ),
    );
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
      appBar: AppBar(title: const Text("Вход")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                field("Email", _email),
                field("Пароль", _pass,
                    obscure: hide1, toggle: () => setState(() => hide1 = !hide1)),
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
                            child: Text("Войти"),
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
