import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';


@immutable      // immutable decorator makes the contents of this class immutable upon inititalisation
class AuthUser {
  final bool isEmailverified;
  const AuthUser(this.isEmailverified);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);

}
