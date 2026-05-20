import 'package:flutter/material.dart';

class GradientCardButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onPressed;

  const GradientCardButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradient,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity, // Растягиваем кнопку на всю доступную ширину
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20.0), // Отступы от краев экрана
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha((255 * 0.4).round()),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withAlpha((255 * 0.2).round()),
              ),
            ),
            Padding(
              // right: 80.0 не дает тексту наехать на большую иконку справа
              padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Центрируем текст по вертикали
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      maxLines: 2, // Ограничиваем количество строк
                      overflow: TextOverflow.ellipsis, // Ставим троеточие, если текст не влезает
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}