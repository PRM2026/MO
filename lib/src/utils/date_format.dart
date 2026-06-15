String formatDisplayDateTime(Object? value, {String fallback = '—'}) {
  if (value == null) return fallback;
  if (value is! String || value.trim().isEmpty) return fallback;

  final date = DateTime.tryParse(value);
  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String formatDisplayTime(Object? value, {String fallback = '—'}) {
  if (value == null) return fallback;
  if (value is! String || value.trim().isEmpty) return fallback;

  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value;

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatDisplayDate(Object? value, {String fallback = '—'}) {
  if (value == null) return fallback;
  if (value is! String || value.trim().isEmpty) return fallback;

  final date = DateTime.tryParse(value);
  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
