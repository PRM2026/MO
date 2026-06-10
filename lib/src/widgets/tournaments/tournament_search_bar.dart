import 'package:flutter/material.dart';

import '../../constants/tournament_colors.dart';

class TournamentSearchBar extends StatelessWidget {
  const TournamentSearchBar({
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
      style: const TextStyle(fontSize: 16, color: TournamentColors.primary),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm giải đấu...',
        hintStyle: TextStyle(
          fontSize: 16,
          color: TournamentColors.outline.withValues(alpha: 0.9),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: TournamentColors.outline.withValues(alpha: 0.9),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TournamentColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: TournamentColors.secondary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
