abstract final class UsernameUtils {
  static String deriveFromEmail(String email) {
    var name = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (name.length < 3) {
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      name = 'user_$name${suffix.substring(suffix.length - 4)}';
    }
    if (name.length > 50) {
      return name.substring(0, 50);
    }
    return name;
  }
}
