class UserProfile {
  String email;
  String username;
  String firstName;
  String lastName;

  UserProfile(this.email, this.username, this.firstName, this.lastName);

  UserProfile.fromJson(Map userProfileJson) {
    this.email = userProfileJson['email'];
    this.username = userProfileJson['username'];
    this.firstName = userProfileJson['firstName'];
    this.lastName = userProfileJson['lastName'];
  }

  static Map toJson(UserProfile userProfile) {
    final userProfileMap = new Map();
    userProfileMap['email'] = userProfile.email;
    userProfileMap['username'] = userProfile.username;
    userProfileMap['firstName'] = userProfile.firstName;
    userProfileMap['lastName'] = userProfile.lastName;

    return userProfileMap;
  }
}
