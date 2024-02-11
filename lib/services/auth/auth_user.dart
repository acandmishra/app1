import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';


@immutable      // immutable decorator makes the contents of this class immutable upon inititalisation
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email,required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(email:user.email,isEmailVerified:user.emailVerified);
}
 