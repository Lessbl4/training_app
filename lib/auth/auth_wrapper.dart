import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/main_navigation.dart';
import '../presentation/screens/onboarding/welcome_screen.dart';
import '../presentation/screens/onboarding/onboarding_container.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (!authSnap.hasData) {
          return const WelcomeScreen();
        }

        final uid = authSnap.data!.uid;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const OnboardingContainer();
            }

            final data = userSnap.data!.data() as Map<String, dynamic>;



if (data.containsKey("isRegistrationComplete") && data["isRegistrationComplete"]) {
              return const MainNavigation();
            } else {
              return const OnboardingContainer();
            }
          },
        );
      },
    );
  }
}
