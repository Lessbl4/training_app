import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/presentation/screens/auth/auth_container.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100),
          Hero(
            tag: 'logo',
            child: Icon(
              CupertinoIcons.flame_fill,
              size: 105, // 150 * 0.7 = 105
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'Gymify',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 150,
            child: CustomPaint(painter: WavePainter()),
            ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal).copyWith(bottom: 60),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const AuthContainer()),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 8,
                      shadowColor: theme.colorScheme.primary.withAlpha(128),
                    ),
                    child: const Text('Я новый пользователь'),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const AuthContainer()),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      side: BorderSide(color: theme.primaryColor, width: 2),
                      minimumSize: const Size(double.infinity, 56),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('У меня уже есть аккаунт'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepGray.withAlpha(128)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
