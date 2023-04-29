import 'package:brew_crew/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // create user obj
  MyUser? _userfromFirebase(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  Stream<MyUser> get user {
    return _auth.authStateChanges().map((User? user) => _userfromFirebase(user!)!);
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential credential = await _auth.signInAnonymously();
      User? user = credential.user;
      return _userfromFirebase(user!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    }
    catch(e){
      print(e);
      return null;
    }
  }

  Future registerEmailPassword(String email, String password) async{
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      return _userfromFirebase(user!);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signInEmailPassword(String email, String password) async{
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      return _userfromFirebase(user!);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }


}