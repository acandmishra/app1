// Login Exceptions
class UserNotFoundAuthException implements Exception{}
class WrongPasswordAuthException implements Exception{}

// Register Exceptions
class EmailAlredayInUseAuthException implements Exception{}
class WeakPasswordAuthException implements Exception{}
class InvalidEmailAuthException implements Exception{}

// Generic Exceptions
class GenericAuthException implements Exception{}
class UserNotLoggedInAuthException implements Exception{}

