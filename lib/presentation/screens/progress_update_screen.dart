import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/services/ai_trainer_service.dart';
import 'package:training_app/services/ai_loading_screen.dart';

class ProgressUpdateScreen extends StatefulWidget {
  final double currentWeight;

  const ProgressUpdateScreen({super.key, required this.currentWeight});

  @override
  State<ProgressUpdateScreen> createState() => _ProgressUpdateScreenState();
}

class _ProgressUpdateScreenState extends State<ProgressUpdateScreen> {
  late double _newWeight;
  double _strengthFeeling = 1.0; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ИСПРАВЛЕНИЕ: принудительно ограничиваем вес в диапазоне слайдера, чтобы избежать исключения
    _newWeight = widget.currentWeight.clamp(40.0, 150.0);
  }

  void _recalculatePlan() async {
    setState(() => _isLoading = true);
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await DatabaseService().updateUserProfile({
        'вес': _newWeight,
        if (_strengthFeeling > 1.1) 'опыт': 'Опытный', 
      });
    }

    AITrainerService.resetAndBoostPlan(_strengthFeeling);

    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AILoadingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Переоценка сил ⚡'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Адаптация нейросети",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Твои мышцы привыкают к нагрузке. Давай обновим данные, чтобы план продолжал давать результат.",
              style: TextStyle(fontSize: 16, color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 40),

            const Text("Твой текущий вес (кг)", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_newWeight.toStringAsFixed(1), style: const TextStyle(fontSize: 32, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _newWeight,
                    min: 40,
                    max: 150,
                    divisions: 110,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) => setState(() => _newWeight = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            const Text("Как ощущаются рабочие веса?", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Slider(
                    value: _strengthFeeling,
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    activeColor: Colors.purpleAccent,
                    onChanged: (val) => setState(() => _strengthFeeling = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Стало тяжело", style: TextStyle(color: _strengthFeeling < 1.0 ? Colors.redAccent : Colors.white54)),
                      Text("Нормально", style: TextStyle(color: _strengthFeeling == 1.0 ? Colors.white : Colors.white54)),
                      Text("Слишком легко", style: TextStyle(color: _strengthFeeling > 1.0 ? Colors.greenAccent : Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _recalculatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Обновить план и веса", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}