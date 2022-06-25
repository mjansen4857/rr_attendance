import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  static Future<User?> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    UserCredential authResult =
        await _firebaseAuth.signInWithCredential(oauthCredential);

    User? user = authResult.user;

    if (user != null) {
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        await user.updateDisplayName(
            appleCredential.givenName! + ' ' + appleCredential.familyName!);
      }
      return getCurrentUser();
    }
    return null;
  }

  static String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    return _firebaseAuth.signOut();
  }
}
