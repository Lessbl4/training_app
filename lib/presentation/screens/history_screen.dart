import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:training_app/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final sessions = HistoryService.sessions;
    final totalTonnage = HistoryService.totalAllTimeTonnage;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Анимированный AppBar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: const Text(
                'ИСТОРИЯ 📜',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24, letterSpacing: 1.2),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
  width: 200, height: 200,
  decoration: const BoxDecoration(
    shape: BoxShape.circle, 
    color: Color.fromRGBO(68, 138, 255, 0.2), // Синий цвет
  ),
),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF0F0F0F)],
                      ),
                    ),
                  ),
                  if (sessions.isNotEmpty)
                    Positioned(
                      bottom: 60, left: 20, right: 20,
                      child: Column(
                        children: [
                          const Text("ОБЩИЙ ТОННАЖ ЗА ВСЕ ВРЕМЯ", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text("${totalTonnage.toInt()} КГ", style: const TextStyle(color: Colors.blueAccent, fontSize: 36, fontWeight: FontWeight.w900)),
                        ],
                      ).animate().fadeIn(duration: 800.ms).slideY(),
                    ),
                ],
              ),
            ),
          ),

          // Тело списка
          if (sessions.isEmpty)
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = sessions[index];
                    return _buildHistoryCard(session, index);
                  },
                  childCount: sessions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(WorkoutSessionModel session, int index) {
    String dateStr = DateFormat('dd MMM yyyy, HH:mm').format(session.startTime);
    int m = session.durationInSeconds ~/ 60;
    
    return Container(
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
              right: -30, top: -30,
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
                  Text(session.workoutType, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _miniStat(CupertinoIcons.timer, "$m мин"),
                      const SizedBox(width: 16),
                      _miniStat(CupertinoIcons.chart_bar_alt_fill, "${session.totalTonnage.toInt()} кг"),
                      const SizedBox(width: 16),
                      _miniStat(CupertinoIcons.bolt_fill, "${session.exercises.length} упр"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 8),
                  const Text("Упражнения:", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: session.exercises.take(4).map((ex) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                      child: Text(ex.name, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    )).toList()..addAll(
                      session.exercises.length > 4 ? [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text("+${session.exercises.length - 4}", style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      ] : [],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
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