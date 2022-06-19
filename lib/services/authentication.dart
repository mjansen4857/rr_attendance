import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<User?> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account != null) {
      GoogleSignInAuthentication auth = await account.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);
      return authResult.user;
    }
    return null;
  }

  static Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    return _firebaseAuth.signOut();
  }
}
