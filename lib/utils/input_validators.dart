String validateEmail(String email) {
  final emailRegEx = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  if (email == null || email.isEmpty) {
    return 'Email cannot be empty';
  } else if (!emailRegEx.hasMatch(email)) {
    return 'Email is not valid';
  } else {
    return null;
  }
}

String validatePassword(String password) {
  if (password == null || password.isEmpty) {
    return 'Password cannot be empty';
  } else if (password.length < 8) {
    return 'Password is too short';
  } else {
    return null;
  }
}
