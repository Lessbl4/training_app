import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:training_app/presentation/screens/classic_workouts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClassicWorkoutsScreen()),
            );
          },
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 250,
            borderRadius: 28.0,
            blur: 15,
            alignment: Alignment.bottomCenter,
            border: 1.5,
            linearGradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade900,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withAlpha((255 * 0.8).round()),
                Colors.white.withAlpha((255 * 0.2).round()),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text(
                    "Классические тренировки",
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
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
