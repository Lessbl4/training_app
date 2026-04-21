import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/ui_constants.dart';
import '../../widgets/custom_error_dialog.dart';
import '../../../auth/auth_service.dart';

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

    String? res = await _auth.login(_email.text.trim(), _pass.text.trim());

    if (!mounted) return;

    if (res != null) {
      showDialog(
        context: context,
        builder: (context) => CustomErrorDialog(message: res),
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

    final result = await _auth.reset(_email.text.trim());

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (result != null) {
      showDialog(
        context: context,
        builder: (context) => CustomErrorDialog(message: result),
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

  void _signInWithGoogle() async {
    setState(() {
      loading = true;
    });
    final result = await _auth.signInWithGoogle();
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
        ),
      );
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
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
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: submit,
                        child: const Text("Войти"),
                      ),
                    ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Войти через Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
