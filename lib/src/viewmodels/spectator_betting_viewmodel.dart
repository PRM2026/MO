import 'package:flutter/foundation.dart';

import '../models/betting_models.dart';
import '../services/betting_service.dart';

class SpectatorBettingViewModel extends ChangeNotifier {
  SpectatorBettingViewModel({BettingService? service})
    : _service = service ?? BettingService();

  final BettingService _service;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? mutationError;
  List<BetMarket> markets = const [];
  List<BetRecord> bets = const [];
  int? selectedMarketId;
  int? selectedParticipantId;

  BetMarket? get selectedMarket {
    for (final market in markets) {
      if (market.id == selectedMarketId) return market;
    }
    return markets.isEmpty ? null : markets.first;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final values = await Future.wait<Object>([
        _service.getBettableMarkets(),
        _service.getMyBets(),
      ]);
      markets = values[0] as List<BetMarket>;
      bets = List<BetRecord>.of(values[1] as List<BetRecord>)
        ..sort((a, b) => _compareDate(b.placedAt, a.placedAt));
      if (markets.isNotEmpty) selectMarket(markets.first.id, notify: false);
    } catch (error) {
      errorMessage = _message(error, 'Không thể tải dữ liệu đặt cược.');
      markets = const [];
      bets = const [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectMarket(int id, {bool notify = true}) {
    selectedMarketId = id;
    BetMarket? market;
    for (final item in markets) {
      if (item.id == id) market = item;
    }
    selectedParticipantId = market?.options.isEmpty == false
        ? market!.options.first.participantId
        : null;
    mutationError = null;
    if (notify) notifyListeners();
  }

  void selectParticipant(int id) {
    selectedParticipantId = id;
    mutationError = null;
    notifyListeners();
  }

  String? validateStake(String value) {
    final market = selectedMarket;
    if (market == null) return 'Vui lòng chọn kèo cược.';
    if (selectedParticipantId == null) return 'Vui lòng chọn ngựa.';
    final amount = num.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null || amount <= 0) {
      return 'Số tiền cược phải lớn hơn 0.';
    }
    if (market.minStake > 0 && amount < market.minStake) {
      return 'Số tiền thấp hơn mức tối thiểu.';
    }
    if (market.maxStake > 0 && amount > market.maxStake) {
      return 'Số tiền vượt mức tối đa.';
    }
    if (!market.isOpen) return 'Kèo cược hiện không mở.';
    return null;
  }

  Future<bool> placeBet(String stakeText) async {
    final validation = validateStake(stakeText);
    if (validation != null) {
      mutationError = validation;
      notifyListeners();
      return false;
    }
    final market = selectedMarket!;
    final amount = num.parse(stakeText.replaceAll(RegExp(r'[^\d.]'), ''));
    isSubmitting = true;
    mutationError = null;
    notifyListeners();
    try {
      final result = await _service.placeBet(
        raceId: '${market.raceId}',
        participantId: selectedParticipantId!,
        stakeAmount: amount,
      );
      bets = [result, ...bets];
      return true;
    } catch (error) {
      mutationError = _message(error, 'Đặt cược thất bại.');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}

int _compareDate(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return -1;
  if (right == null) return 1;
  return left.compareTo(right);
}

String _message(Object error, String fallback) {
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  return text.isEmpty ? fallback : text;
}
