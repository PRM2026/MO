import 'package:http/http.dart' as http;

import '../models/deposit_order_response.dart';
import '../models/wallet_response.dart';
import '../models/wallet_transaction_response.dart';
import '../models/withdrawal_response.dart';
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

  Future<WalletResponse> getWallet() {
    return _apiClient.getObject('/wallets/me', WalletResponse.fromJson);
  }

  Future<List<WalletTransactionResponse>> getTransactions() {
    return _apiClient.getList(
      '/wallets/me/transactions',
      WalletTransactionResponse.fromJson,
    );
  }

  Future<List<WalletTransactionResponse>> getJockeyPrizes() {
    return _apiClient.getList(
      '/jockey/prizes',
      WalletTransactionResponse.fromJson,
    );
  }

  Future<DepositOrderResponse> createDepositOrder({
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
      DepositOrderResponse.fromJson,
    );
  }

  Future<List<DepositOrderResponse>> getDepositOrders() {
    return _apiClient.getList(
      '/wallets/me/deposit-orders',
      DepositOrderResponse.fromJson,
    );
  }

  Future<DepositOrderResponse> getDepositOrder(String id) {
    return _apiClient.getObject(
      '/wallets/me/deposit-orders/$id',
      DepositOrderResponse.fromJson,
    );
  }

  Future<WithdrawalResponse> createWithdrawal({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? reason,
  }) {
    final body = <String, dynamic>{
      'amount': amount,
      'bankName': bankName.trim(),
      'bankAccountNumber': bankAccountNumber.trim(),
      'bankAccountName': bankAccountName.trim(),
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };
    return _apiClient.postObject(
      '/wallets/me/withdrawals',
      body,
      WithdrawalResponse.fromJson,
    );
  }

  Future<List<WithdrawalResponse>> getWithdrawals() {
    return _apiClient.getList(
      '/wallets/me/withdrawals',
      WithdrawalResponse.fromJson,
    );
  }

  Future<WithdrawalResponse> getWithdrawal(String id) {
    return _apiClient.getObject(
      '/wallets/me/withdrawals/$id',
      WithdrawalResponse.fromJson,
    );
  }
}
