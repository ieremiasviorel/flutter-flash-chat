import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/user_profile.dart';

class UserService {
  UserService._privateConstructor();

  static final UserService _instance = UserService._privateConstructor();

  static UserService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;

  Future<AuthResult> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<AuthResult> authenticate(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<FirebaseUser> getCurrentUser() {
    return _auth.currentUser();
  }

  Future<UserProfile> getUserProfile(String userEmail) {
    return _store
        .collection('profiles')
        .document(userEmail)
        .get()
        .then((userProfileDocument) => userProfileDocument.data)
        .then((userProfileData) => userProfileData != null
            ? UserProfile.fromJson(userProfileData)
            : null);
  }

  Future<UserProfile> setUserProfile(UserProfile userProfile) async {
    print(userProfile);
    print(UserProfile.toJson(userProfile));
    await _store
        .collection('profiles')
        .document(userProfile.email)
        .setData(UserProfile.toJson(userProfile));
    print('Here we gucci');
    return userProfile;
  }

  Future<List<UserProfile>> getUserContacts(String userEmail) {
    return _store
        .collection('contacts')
        .document(userEmail)
        .get()
        .then((userContactsDocument) => userContactsDocument.data)
        .then((userContactsData) =>
            userContactsData != null ? userContactsData['contacts'] : null)
        .then((userContactsList) => userContactsList
            ? userContactsList
                .map<UserProfile>(
                    (userProfileJson) => UserProfile.fromJson(userProfileJson))
                .toList()
            : null);
  }
}
