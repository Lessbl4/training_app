import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  void _showWorkoutDetails(BuildContext context, Map<String, dynamic> sessionData) {
    final exercises = sessionData['exercises'] as List<dynamic>? ?? [];
    final startTimeStr = sessionData['startTime'] as String?;
    final startTime = startTimeStr != null ? DateTime.tryParse(startTimeStr) ?? DateTime.now() : DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 40)],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Text(sessionData['workoutType'] ?? 'Тренировка', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(DateFormat('dd.MM.yyyy, HH:mm').format(startTime), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 24),
                  
                  const Text("Выполненные упражнения 🏆", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ...exercises.map((ex) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(CupertinoIcons.checkmark_alt, color: Colors.blueAccent, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex['name'] ?? 'Упражнение', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Вес: ${ex['weight']} • Сеты: ${ex['reps']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: Text("Войдите в аккаунт", style: TextStyle(color: Colors.white54))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid!)
            .collection('history')
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
          }

          final docs = snapshot.data?.docs ?? [];
          
          double totalTonnage = 0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalTonnage += (data['totalTonnage'] ?? 0.0).toDouble();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0F0F0F),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: const Text('ИСТОРИЯ 📜', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22, letterSpacing: 1.2)),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: -50, right: -50,
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15))),
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xFF0F0F0F)]),
                        ),
                      ),
                      if (docs.isNotEmpty)
                        Positioned(
                          bottom: 60, left: 20, right: 20,
                          child: Column(
                            children: [
                              const Text("ОБЩИЙ ТОННАЖ ЗА ВСЕ ВРЕМЯ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 4),
                              Text("${totalTonnage.toInt()} КГ", style: const TextStyle(color: Colors.blueAccent, fontSize: 40, fontWeight: FontWeight.w900)),
                            ],
                          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                        ),
                    ],
                  ),
                ),
              ),

              if (docs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.time, size: 80, color: Colors.white10),
                        const SizedBox(height: 16),
                        const Text("Тут пока пусто 🤷‍♂️", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Сделай первую тренировку,\nчтобы начать писать историю!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildHistoryCard(context, data, index);
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data, int index) {
    final startTimeStr = data['startTime'] as String?;
    final startTime = startTimeStr != null ? DateTime.tryParse(startTimeStr) ?? DateTime.now() : DateTime.now();
    String dateStr = DateFormat('dd.MM.yyyy, HH:mm').format(startTime);
    
    int duration = data['durationInSeconds'] ?? 0;
    int m = duration ~/ 60;
    
    double tonnage = (data['totalTonnage'] ?? 0.0).toDouble();
    List<dynamic> exercises = data['exercises'] ?? [];
    
    return GestureDetector(
      onTap: () => _showWorkoutDetails(context, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20, top: -20,
                child: Icon(CupertinoIcons.flame_fill, size: 120, color: Colors.white.withOpacity(0.02)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text("Выполнено", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(data['workoutType'] ?? 'Тренировка', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _miniStat(CupertinoIcons.timer, "$m мин"),
                        const SizedBox(width: 16),
                        _miniStat(CupertinoIcons.chart_bar_alt_fill, "${tonnage.toInt()} кг"),
                        const SizedBox(width: 16),
                        _miniStat(CupertinoIcons.bolt_fill, "${exercises.length} упр"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _miniStat(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 16),
        const SizedBox(width: 6),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}