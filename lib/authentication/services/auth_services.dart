import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> loggedUser(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return ('User not found, please sign up first.');
        case 'invalid-credential':
          return ('Incorrect data, please try again.');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> signUpUser(
      {required String name,
      required String email,
      required String password}) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await user.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return ('The account already exists. Please sign in.');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> forgottenPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return ('User not found, please sign up first.');
        case 'channel-error':
          return ('Insert a valid email.');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'channel-error':
          return ('Error signing out.');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> removeAccount({required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!, password: password);
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}
