import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    
    await googleSignIn.initialize(
      serverClientId: '787688938152-4b6ut8k22r8qono6e0e7ratmmap7u4he.apps.googleusercontent.com',
    );

    final GoogleSignInAccount? gUser = await googleSignIn.authenticate();
    if (gUser == null) return null; 

    final GoogleSignInAuthentication gAuth = gUser.authentication; 
    
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
    );

    UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);

    final doc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();
    
    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'электронная почта': userCred.user!.email ?? '',
        'имя': userCred.user!.displayName ?? 'Пользователь',
        'фото': userCred.user!.photoURL ?? '',
        'isRegistrationComplete': false, 
        'isPro': false,
      });
    }

    return userCred;
  }
}