class UserDisplay {
  static String handle(String email) {
    if (email.isEmpty) return '@usuario';
    final name = email.split('@').first;
    return '@$name';
  }

  static String initial(String email) {
    final h = handle(email).replaceFirst('@', '');
    return h.isNotEmpty ? h[0].toUpperCase() : '?';
  }
}
