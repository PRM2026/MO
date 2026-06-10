import 'package:flutter/material.dart';

import '../../constants/news_colors.dart';

class NewsSearchBar extends StatelessWidget {
  const NewsSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: NewsColors.navy),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tin tức...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: NewsColors.textMuted.withValues(alpha: 0.8),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: NewsColors.textMuted.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: NewsColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: NewsColors.border.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NewsColors.gold, width: 1.5),
        ),
      ),
    );
  }
}
