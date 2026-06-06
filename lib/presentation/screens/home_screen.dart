import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/services/ai_loading_screen.dart';
import 'package:training_app/presentation/screens/classic_workouts_screen.dart';
import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/presentation/widgets/modals/change_goal_modal.dart';
import 'package:training_app/services/sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброе утро';
    if (hour < 17) return 'Добрый день';
    if (hour < 22) return 'Добрый вечер';
    return 'Доброй ночи';
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const Scaffold(backgroundColor: AppColors.background);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserModel>(
        stream: DatabaseService().getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          final user = snapshot.data!;
          final firstName = user.name?.split(' ').first ?? 'Атлет';
          final isPro = user.isPro; // ПРОВЕРКА PRO-ВЕРСИИ

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 110,
                pinned: true,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Row(
                                children: [
                                  Text(firstName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                                  // --- PRO БЕЙДЖ ---
                                  if (isPro) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF97316)]),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                    ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
                                  ]
                                ],
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surfaceLight,
                            backgroundImage: user.photo != null && user.photo!.isNotEmpty ? NetworkImage(user.photo!) : null,
                            child: user.photo == null || user.photo!.isEmpty ? const Icon(CupertinoIcons.person_solid, color: AppColors.primary, size: 20) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- ГЛАВНАЯ КАРТОЧКА ИИ ---
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AILoadingScreen())),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppBorderRadius.circularMedium,
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
                          ),
                          child: Stack(
                            children: [
                              Positioned(right: -20, top: -20, child: Icon(CupertinoIcons.bolt_fill, size: 120, color: Colors.white.withOpacity(0.2))),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: const Text("AI Тренер", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text("Сгенерировать\nПлан Тренировки", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                                  const SizedBox(height: 12),
                                  const Text("Адаптируется под твою ЦНС и веса", style: TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.02, duration: 2.seconds, curve: Curves.easeInOut),
                      ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),

                      const Text("ТРЕНИРОВКИ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5)).animate().fade(delay: 200.ms),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildGlassCard(title: "Классика", subtitle: "Базовые программы", icon: CupertinoIcons.flame_fill, color: AppColors.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClassicWorkoutsScreen())))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGlassCard(title: "История", subtitle: "Твой прогресс", icon: CupertinoIcons.chart_bar_alt_fill, color: AppColors.secondary, onTap: () {})),
                        ],
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),

                      // --- ИЗМЕНЯЕМАЯ КАРТОЧКА ЦЕЛИ ---
                      GestureDetector(
                        onTap: () {
                          SoundService.playClick();
                          showGlassmorphicModal(
                            context: context,
                            builder: (context) => ChangeGoalModal(currentGoal: user.goal ?? '', uid: uid!),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppBorderRadius.circularMedium,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(CupertinoIcons.flag_fill, color: AppColors.success),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Текущая цель", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(user.goal ?? "Не указана", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(CupertinoIcons.pencil, color: Colors.white70, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 100), // Отступ для плавающего меню
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppBorderRadius.circularMedium,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.glassBackground, borderRadius: AppBorderRadius.circularMedium, border: Border.all(color: AppColors.glassBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}