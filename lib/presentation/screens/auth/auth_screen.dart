import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/screens/main_navigation.dart';
import 'package:training_app/auth/auth_service.dart';
import 'package:training_app/auth/onboarding_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  final _auth = AuthService();

  bool isLogin = true;
  bool hide1 = true;
  bool hide2 = true;
  bool loading = false;
  String error = "";

  late AnimationController _fade;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeIn);
    _fade.forward();
  }

  @override
  void dispose() {
    _fade.dispose();
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

    if (!isLogin) {
      if (_pass.text != _confirm.text) {
        setState(() {
          error = "Пароли не совпадают";
          loading = false;
        });
        return;
      }

      // Валидация пароля: 8 символов, заглавная, цифра, спецсимвол
      String p = _pass.text;
      bool hasUpper = p.contains(RegExp(r'[A-Z]'));
      bool hasDigits = p.contains(RegExp(r'[0-9]'));
      bool hasSpecial = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

      if (p.length < 8 || !hasUpper || !hasDigits || !hasSpecial) {
        setState(() {
          error =
              "Пароль должен быть от 8 символов и содержать:\n• заглавную букву\n• цифру\n• спецсимвол (!@#\$%^&*)";
          loading = false;
        });
        return;
      }
    }

    String? res = isLogin
        ? await _auth.login(_email.text.trim(), _pass.text.trim())
        : await _auth.register(_email.text.trim(), _pass.text.trim());

    if (!mounted) return;

    if (res != null) {
      setState(() {
        error = res;
        loading = false;
      });
      return;
    }

if (!isLogin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Аккаунт успешно создан"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (_) =>
              isLogin ? const MainNavigation() : const OnboardingScreen(),
        ),
      );
    }
  }

  Future<void> reset() async {
    if (_email.text.isEmpty) {
      setState(() => error = "Введи email для сброса пароля");
      return;
    }

    setState(() {
      error = "";
      loading = true;
    });

    final result = await _auth.reset(_email.text.trim());

    if (!mounted) return;

    setState(() {
      loading = false;
      error = result ?? "Письмо для сброса пароля отправлено";
    });
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
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Icon(CupertinoIcons.flame_fill,
                      size: 70, color: theme.colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    "GYMIFY",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isLogin ? "Вход" : "Регистрация",
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        field("Email", _email),
                        field("Пароль", _pass,
                            obscure: hide1,
                            toggle: () => setState(() => hide1 = !hide1)),
                        if (!isLogin)
                          field("Повтори пароль", _confirm,
                              obscure: hide2,
                              toggle: () =>
                                  setState(() => hide2 = !hide2)),
                        if (error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              error,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: error.contains("отправлено")
                                    ? Colors.greenAccent
                                    : theme.colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 10),
                        loading
                            ? const CupertinoActivityIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: submit,
                                  child: Text(
                                    isLogin ? "Войти" : "Создать аккаунт",
                                  ),
                                ),
                              ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                              error = "";
                            });
                          },
                          child: Text(
                            isLogin
                                ? "Нет аккаунта? Регистрация"
                                : "Уже есть аккаунт? Войти",
                          ),
                        ),
                        if (isLogin)
                          TextButton(
                            onPressed: reset,
                            child: Text(
                              "Забыли пароль?",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(153),
                                ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}