import 'package:flutter/material.dart';

class StatMetric {
  const StatMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}
