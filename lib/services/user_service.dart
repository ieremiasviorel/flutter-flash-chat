import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/user_invitation.dart';
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

  Future<UserProfile> getUserProfileByEmail(String userEmail) {
    return _store
        .collection('profiles')
        .document(userEmail)
        .get()
        .then((userProfileDocument) => userProfileDocument.data)
        .then((userProfileData) => userProfileData != null
            ? UserProfile.fromJson(userProfileData)
            : null);
  }

  Future<UserProfile> getUserProfileByUsername(String username) {
    return _store
        .collection('profiles')
        .where('username', isEqualTo: username)
        .getDocuments()
        .then((userProfileQueryResult) => userProfileQueryResult.documents)
        .then((userProfileDocuments) => userProfileDocuments[0])
        .then((userProfileDocument) => userProfileDocument.data)
        .then((userProfileData) => userProfileData != null
            ? UserProfile.fromJson(userProfileData)
            : null);
  }

  Future<UserProfile> setUserProfile(UserProfile userProfile) async {
    await _store
        .collection('profiles')
        .document(userProfile.email)
        .setData(UserProfile.toJson(userProfile));

    return userProfile;
  }

  Future<List<UserProfile>> getUserContacts(String userEmail) async {
    final userContactsData = await _store
        .collection('contacts')
        .document(userEmail)
        .get()
        .then((userContactsDocument) => userContactsDocument.data)
        .then((userContactsData) =>
            userContactsData != null ? userContactsData['contacts'] : null);

    if (userContactsData != null) {
      return userContactsData
          .map<UserProfile>(
              (userProfileJson) => UserProfile.fromJson(userProfileJson))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<UserProfile>> setUserContacts(
      String userEmail, List<UserProfile> userContacts) async {
    final userContactsData = new Map<String, dynamic>();

    userContactsData['contacts'] = userContacts
        .map((userContact) => UserProfile.toJson(userContact))
        .toList();

    await _store
        .collection('contacts')
        .document(userEmail)
        .setData(userContactsData);

    return userContacts;
  }

  Future<List<UserProfile>> addUserContact(
      String userEmail, UserProfile userContact) async {
    final List<UserProfile> userContacts = await getUserContacts(userEmail);
    userContacts.add(userContact);
    await setUserContacts(userEmail, userContacts);

    return userContacts;
  }

  Future<List<UserInvitation>> getUserInvitations(String username) async {
    return await _store
        .collection('invitations')
        .where('invited', isEqualTo: username)
        .getDocuments()
        .then((invitationsQueryResult) => invitationsQueryResult.documents)
        .then((invitationsDocuments) => invitationsDocuments
            .map((invitationDocument) => invitationDocument.data)
            .toList())
        .then((invitationsData) => invitationsData
            .map((invitationData) => UserInvitation.fromJson(invitationData))
            .toList());
  }

  Future<UserInvitation> setUserInvitation(
      UserInvitation userInvitation) async {
    await _store
        .collection('invitations')
        .document(invitationDocumentKey(userInvitation))
        .setData(UserInvitation.toJson(userInvitation));

    return userInvitation;
  }

  Future<UserInvitation> acceptInvitation(UserInvitation userInvitation) async {
    final UserProfile inviter = userInvitation.inviter;
    final UserProfile invited =
        await getUserProfileByUsername(userInvitation.invited);

    addUserContact(inviter.email, invited);
    addUserContact(invited.email, inviter);

    await deleteInvitation(userInvitation);

    return userInvitation;
  }

  Future<UserInvitation> deleteInvitation(UserInvitation userInvitation) async {
    await _store
        .collection('invitations')
        .document(invitationDocumentKey(userInvitation))
        .delete();

    return userInvitation;
  }

  String invitationDocumentKey(UserInvitation userInvitation) {
    return userInvitation.inviter.username + '-' + userInvitation.invited;
  }
}
