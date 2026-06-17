String formatVnd(num? value) {
  final amount = (value ?? 0).round();
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}${buffer.toString()} đ';
}

String formatVndCompact(num? value) {
  final amount = (value ?? 0).toDouble().abs();
  if (amount >= 1000000000) {
    return '${(amount / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
  }
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
  }
  return amount.round().toString();
}
