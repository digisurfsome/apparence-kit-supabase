import 'dart:async';

import 'package:apparence_kit/firebase_options_dev.dart';
import 'package:apparence_kit/modules/authentication/api/authentication_api_interface.dart';
import 'package:apparence_kit/modules/authentication/repositories/exceptions/authentication_exceptions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:apparence_kit/core/data/entities/user_entity.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

final authenticationApiProvider = Provider<AuthenticationApi>(
  (ref) => FirebaseAuthenticationApi(
    FirebaseAuth.instance, 
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);

class FirebaseAuthenticationApi implements AuthenticationApi {
  
  final FirebaseAuth _auth;
  
  // ignore: unused_field - this is just to show you how to use Firebase Functions if needed
  final FirebaseFunctions _firebaseFunctions;
  
  User? _user;
  
  bool hasInit = false;

  FirebaseAuthenticationApi(this._auth, this._firebaseFunctions);

  @override
  Future<void> init() async {
    _auth.userChanges().listen((event) {
      if (!hasInit) {
        hasInit = true;
      }
      _user = event;
    });
    while (!hasInit) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Stream<Credentials?> onAuthStateChange() {
    return _auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return Credentials(
        id: user.uid,
        token: "",
      );
    });
  }

  @override
  Future<Credentials?> get() async {
    if (_user != null) {
      return Future.value(Credentials(id: _user!.uid, token: ""));
    }
    return null;
  }

  @override
  Future<Credentials> signinAnonymously() {
    return _auth.signInAnonymously().then(
          (value) => Credentials(
            id: value.user!.uid,
            token: value.credential?.token.toString() ?? '',
          ),
          onError: (error) {
            Logger().e("Error while signing in anonymously: $error");
            Logger().e(
                "Please check you enabled anonymous sign-in in Firebase: https://firebase.google.com/docs/auth/flutter/anonymous-auth");
            return error;
          },
        );
  }

  @override
  Future<Credentials> signin(String email, String password) {
    return _auth
      .signInWithEmailAndPassword(email: email, password: password)
      .then(
        (value) => Credentials(
          id: value.user!.uid,
          token: value.credential?.token.toString() ?? '',
        ),
      );
  }

  @override
  Future<void> recoverPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signout() {
    _user = null;
    return _auth.signOut();
  }

  @override
  Future<Credentials> signup(String email, String password) async {
    if (_auth.currentUser == null) {
      return _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
            (value) => Credentials(
              id: value.user!.uid,
              token: value.credential?.token.toString() ?? '',
            ),
          );
    }
    final credentials = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final resultUser = await _auth.currentUser!.linkWithCredential(credentials);
    return Credentials(
      id: resultUser.user!.uid,
      token: resultUser.credential?.token.toString() ?? '',
    );
  }

  @override
  Future<Credentials> signinWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope(
        'https://www.googleapis.com/auth/contacts.readonly',
      );
      // Optionally you can add custom parameters to the provider
      // googleProvider.setCustomParameters({
      //   'login_hint': 'user@example.com'
      // });
      final credentials = await _auth.signInWithPopup(googleProvider);

      return Credentials(
        id: credentials.user!.uid,
        token: credentials.credential?.token.toString() ?? '',
      );
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth
        .signInWithCredential(credential)
        .then((value) => Credentials(id: value.user!.uid, token: ''));
    
  }

  /// Sign up with Google and link the account to the current anonymous user.
  /// The anonymous account will now be linked to the Google account.
  /// The user can now sign in with the Google account.
  /// His data will be preserved.
  @override
  Future<Credentials> signupFromAnonymousWithGoogle() async {
    
    final googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    final credentials = await _auth.currentUser! //
        .linkWithProvider(googleProvider);
    return Credentials(
      id: credentials.user!.uid,
      token: credentials.credential?.token.toString() ?? '',
    );
    
  }

  @override
  Future<Credentials> signinWithGooglePlay() async {
    throw UnimplementedError();
  }

  @override
  Future<Credentials> signinWithApple() async {
    throw UnimplementedError();
  }

  /// Sign up with Apple and link the account to the current anonymous user.
  /// The anonymous account will now be linked to the Apple account.
  /// The user can now sign in his Apple account on another device. 
  /// His data will be preserved.
  @override
  Future<Credentials> signupFromAnonymousWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<Credentials> signinWithFacebook() async {
    throw UnimplementedError();
  }

  @override
  Future<String> signinWithPhone(String phoneNumber) async {
    final normalizedPhoneNumber = _normalizePhoneNumber(phoneNumber);
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedPhoneNumber,
      verificationCompleted: (credentials) async {
        await _auth.signInWithCredential(credentials);
      },
      verificationFailed: (FirebaseAuthException error) {
        if (error.code == 'invalid-phone-number') {
          completer.completeError(
            PhoneAuthException(code: 0, message: 'Invalid phone number'),
          );
          return;
        }
        completer.completeError(
          PhoneAuthException(code: 0, message: 'Unknown error: $error'),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.completeError(
            PhoneAuthException(code: 0, message: 'Code auto retrieval timeout'),
          );
        }
      },
    );

    return completer.future;
  }

  @override
  Future<Credentials> verifyPhoneAuth(String verificationId, String otp) async {
    final phoneProvider = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return _auth
        .signInWithCredential(phoneProvider)
        .then((value) => Credentials(id: value.user!.uid, token: ''));
  }

  @override
  Future<String> updateAuthPhone(String phoneNumber) async {
    final normalizedPhoneNumber = _normalizePhoneNumber(phoneNumber);
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedPhoneNumber,
      verificationCompleted: (credentials) {
        _auth.currentUser!.updatePhoneNumber(
          PhoneAuthProvider.credential(
            verificationId: credentials.verificationId!,
            smsCode: credentials.smsCode!,
          ),
        );
      },
      verificationFailed: (FirebaseAuthException error) {
        if (error.code == 'invalid-phone-number') {
          completer.completeError(
            PhoneAuthException(code: 0, message: 'Invalid phone number'),
          );
          return;
        }
        if (error.code == 'too-many-requests') {
          completer.completeError(PhoneAlreadyLinkedException());
          return;
        }
        completer.completeError(
          PhoneAuthException(code: 0, message: 'Unknown error: $error'),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.completeError(
            PhoneAuthException(code: 0, message: 'Code auto retrieval timeout'),
          );
        }
      },
    );
    return completer.future;
  }

  @override
  Future<Credentials> confirmLinkPhoneAuth(String verificationId, String otp) {
    return _auth.currentUser!
        .updatePhoneNumber(
          PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: otp,
          ),
        )
        .catchError((error) {
          if (error is FirebaseAuthException &&
              error.code == 'credential-already-in-use') {
            throw PhoneAlreadyLinkedException();
          }
          throw "failed_to_confirm_link_phone_auth";
        })
        .then((value) => Credentials(id: _user!.uid, token: ''));
  }

  String _normalizePhoneNumber(String phoneNumber) {
    String normalized = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    return normalized;
  }
}

