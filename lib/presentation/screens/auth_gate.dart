import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/screens/auth/auth_screen.dart';
import 'package:training_app/presentation/screens/main_navigation.dart';
import 'package:training_app/presentation/screens/onboarding/onboarding_container.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AuthScreen();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const OnboardingContainer();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['height'] == null || data['weight'] == null) {
              return const OnboardingContainer();
            }

            return const MainNavigation();
          },
        );
      },
    );
  }
}
