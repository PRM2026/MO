import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_storage.dart';

class RefereeWalletService {
  RefereeWalletService({
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
}
