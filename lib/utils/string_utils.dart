String getInitials(String name) {
  if (name.trim().isEmpty) return "?";

  final parts = name.trim().split(" ");

  if (parts.length == 1) {
    final word = parts[0];
    if (word.length >= 2) {
      return word.substring(0, 2).toUpperCase();
    } else {
      return word[0].toUpperCase();
    }
  }

  return (parts[0][0] + parts[1][0]).toUpperCase();
}
