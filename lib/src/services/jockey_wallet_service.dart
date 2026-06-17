import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_storage.dart';

class JockeyWalletService {
  JockeyWalletService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getWallet() {
    return _apiClient.getObject('/wallets/me', (json) => json);
  }

  Future<List<Map<String, dynamic>>> getTransactions() {
    return _apiClient.getList('/wallets/me/transactions', (json) => json);
  }

  Future<List<Map<String, dynamic>>> getJockeyPrizes() {
    return _apiClient.getList('/jockey/prizes', (json) => json);
  }

  Future<Map<String, dynamic>> createDepositOrder({
    required num amount,
    String currency = 'VND',
    String? provider,
  }) {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      if (provider != null && provider.trim().isNotEmpty)
        'provider': provider.trim(),
    };
    return _apiClient.postObject(
      '/wallets/me/deposit-orders',
      body,
      (json) => json,
    );
  }

  Future<List<Map<String, dynamic>>> getDepositOrders() {
    return _apiClient.getList('/wallets/me/deposit-orders', (json) => json);
  }

  Future<Map<String, dynamic>> getDepositOrder(String id) {
    return _apiClient.getObject(
      '/wallets/me/deposit-orders/$id',
      (json) => json,
    );
  }

  Future<Map<String, dynamic>> createWithdrawal({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? reason,
  }) {
    final body = <String, dynamic>{
      'amount': amount,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };
    return _apiClient.postObject(
      '/wallets/me/withdrawals',
      body,
      (json) => json,
    );
  }

  Future<List<Map<String, dynamic>>> getWithdrawals() {
    return _apiClient.getList('/wallets/me/withdrawals', (json) => json);
  }

  Future<Map<String, dynamic>> getWithdrawal(String id) {
    return _apiClient.getObject('/wallets/me/withdrawals/$id', (json) => json);
  }
}
