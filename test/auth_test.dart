import 'package:app1/services/auth/auth_exceptions.dart';
import 'package:app1/services/auth/auth_provider.dart';
import 'package:app1/services/auth/auth_user.dart';
import 'package:test/test.dart';

// dependency injection is like creating something similar to auth_service as created here in this app which is not 
// using a particular service provider but can accept any such provider, ie. we have a generalised class which can use any provider which we provide
// so the auth_service is like injection in which we can use any provider to be injected in our app

void main(){
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
  
  // Test1
  test("shouldn't be initialized", () {
    expect(provider.isInitialized,false);
  });

  // Test2
  test("Logout error should occur",(){
    expect(provider.logOut(),throwsA(const TypeMatcher<NotInitializedException>()));
  });

  // Test3
  test("should initialize",()async{
    await provider.initialise();
    expect(provider.isInitialized,true);
  });

  // Test4
  test("User null after initialized",(){
    expect(provider.currentUser,null);
  });

  // Test5
  // Testing the timeout 
  // use case:- while making api calls if the time exceeds the given time limit then the test fails
  test('should initialize in the given time limit ,2 seconds', () async{
    await provider.initialise();
    expect(provider.isInitialized,true);    
  },
    timeout:const Timeout(Duration(seconds:2)));

  // Test6
  // Testing the create user function which in return calls login
  test('Create user should result in log in', () async{
    // Testing the wrong user exception
    final wrongUser = provider.createUser(
    email:"acand@mishra.com",
    password:"foobarbaz",
    );
    expect(wrongUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

    // Testing the wrong password exception
    final wrongPassword=provider.createUser(
    email:"acandmishra.com",
    password:"foobar",
    );
    expect(wrongPassword, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

    // Testing when everything is correct
    final correctLogInUser=await provider.createUser(
    email:"acandmishra.com",
    password:"foobarbaz",
    );
    expect(provider.currentUser,correctLogInUser);
    expect(correctLogInUser.isEmailVerified,false);
  });
  // Test7
  // Email verification
  test('Email Verification successful for a user logged in', () {
    provider.sendEmailVerification();
    final user=provider.currentUser;
    expect(user,isNotNull);
    expect(user!.isEmailVerified,true); // we put exclamation to forcefully call the property

  });
  // Test8
  // Test log in and log out again
  test('LogOut and LogIn again', () async{
    await provider.logOut();
    await provider.logIn(email:"email", password: "password");
    final user=provider.currentUser;
    expect(user,isNotNull);
  });


  });
}
class NotInitializedException implements Exception{}
class MockAuthProvider implements AuthProvider{

  // creating a mock user
  AuthUser? _user;

  // Mock initialization
  var _isInitialized =false;
  bool get isInitialized => _isInitialized;

  // MockcreateUser function
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    }) async{
      if (!isInitialized) throw NotInitializedException();
      await Future.delayed(const Duration(seconds: 1));
      return logIn(
      email: email,
      password: password,
      );
  }

  // Mock currentUser getter
  // This sets the above made AuthUser _user our currentUser
  @override
  AuthUser? get currentUser => _user;


  @override
  Future<void> initialise() async{
    await Future.delayed(const Duration(seconds:1));
    _isInitialized=true;
    
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
    }) {
      if (!isInitialized) throw NotInitializedException();
      if (email == "acand@mishra.com") throw UserNotFoundAuthException();
      if (password == "foobar") throw WrongPasswordAuthException();
      const user=AuthUser(isEmailVerified: false);
      _user=user;
      return Future.value(user); 
    }

  @override
  Future<void> logOut() async{
    if (!isInitialized) throw NotInitializedException();
    if (_user==null) throw UserNotFoundAuthException();
    await Future.delayed(Duration(seconds:1));
    _user=null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user =_user;
    if (user==null) throw UserNotFoundAuthException();
    // we created a completely new user below because it was not possible to change the isEmailVerified: parameter 
    // of original user as once set it can not be changed !! coz AuthUser is immutable
    const newUser = AuthUser(isEmailVerified: true);
    _user=newUser;

  }
  
}
// In FlutterAppDevelopmentVideo this section ended at 17:18:42
