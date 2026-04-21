import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String pass) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final user = cred.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'photoURL': user.photoURL,
        }, SetOptions(merge: true));
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _error(e.code);
    }
  }

  Future<String?> register(String email, String pass) async {
    try {
      var cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user!.uid)
          .set({
        "uid": cred.user!.uid,
        "email": email,
        "name": "",
        "photoURL": "",
        "weight": "",
        "height": "",
        "experience": "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _error(e.code);
    }
  }

  Future<String?> reset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _error(e.code);
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return 'Аутентификация отменена';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'photoURL': user.photoURL,
        }, SetOptions(merge: true));

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'weight': 0,
            'height': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _error(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  String _error(String code) {
    switch (code) {
      case 'user-not-found':
        return "Пользователь не найден";
      case 'wrong-password':
        return "Неверный пароль";
      case 'invalid-credential':
        return "Неверный email или пароль";
      case 'invalid-email':
        return "Неверный email";
      case 'email-already-in-use':
        return "Email уже используется";
      case 'weak-password':
        return "Пароль должен содержать минимум 6 символов";
      case 'user-disabled':
        return "Аккаунт заблокирован";
      case 'too-many-requests':
        return "Слишком много попыток. Попробуй позже";
      case 'network-request-failed':
        return "Ошибка сети. Проверь подключение";
      default:
        return "Ошибка: $code";
    }
  }
}
