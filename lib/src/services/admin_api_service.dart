import 'api_client.dart';

typedef JsonMap = Map<String, dynamic>;

class AdminApiService {
  AdminApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static JsonMap _map(JsonMap json) => json;

  Future<JsonMap> getDashboardSummary() =>
      _client.getObject('/admin/dashboard/summary', _map);

  Future<List<JsonMap>> getRevenue({int months = 6}) =>
      _client.getList('/admin/dashboard/revenue?months=$months', _map);

  Future<List<JsonMap>> getUsers() => _client.getList('/admin/users', _map);

  Future<List<JsonMap>> getRoleApplications() =>
      _client.getList('/admin/role-applications', _map);

  Future<JsonMap> activateUser(String id) =>
      _client.putObject('/admin/users/$id/activate', const {}, _map);

  Future<JsonMap> deactivateUser(String id) =>
      _client.putObject('/admin/users/$id/deactivate', const {}, _map);

  Future<JsonMap> updateUserRole(String id, String role) =>
      _client.putObject('/admin/users/$id/role', {'role': role}, _map);

  Future<JsonMap> approveRoleApplication(String id, {String? role}) {
    final suffix = role == null || role.isEmpty ? '' : '?role=$role';
    return _client.putObject(
      '/admin/role-applications/$id/approve$suffix',
      null,
      _map,
    );
  }

  Future<JsonMap> rejectRoleApplication(
    String id, {
    required String reason,
    String? role,
  }) {
    final suffix = role == null || role.isEmpty ? '' : '?role=$role';
    return _client.putObject('/admin/role-applications/$id/reject$suffix', {
      'reason': reason,
    }, _map);
  }

  Future<List<JsonMap>> getHorses({String? status}) {
    final suffix = status == null || status.isEmpty ? '' : '?status=$status';
    return _client.getList('/admin/horses$suffix', _map);
  }

  Future<JsonMap> approveHorse(String id) =>
      _client.putObject('/admin/horses/$id/approve', null, _map);

  Future<JsonMap> rejectHorse(String id, String reason) =>
      _client.putObject('/admin/horses/$id/reject', {'reason': reason}, _map);

  Future<JsonMap> suspendHorse(String id, String reason) =>
      _client.putObject('/admin/horses/$id/suspend', {'reason': reason}, _map);

  Future<List<JsonMap>> getTournaments() =>
      _client.getList('/admin/tournaments', _map);

  Future<JsonMap> getTournament(String id) =>
      _client.getObject('/admin/tournaments/$id', _map);

  Future<JsonMap> createTournament(JsonMap payload) =>
      _client.postObject('/admin/tournaments', payload, _map);

  Future<JsonMap> updateTournament(String id, JsonMap payload) =>
      _client.putObject('/admin/tournaments/$id', payload, _map);

  Future<JsonMap> updateTournamentStatus(String id, String status) => _client
      .putObject('/admin/tournaments/$id/status', {'status': status}, _map);

  Future<JsonMap> addTournamentRace(String id, JsonMap payload) =>
      _client.postObject('/admin/tournaments/$id/races', payload, _map);

  Future<List<JsonMap>> getTournamentRegistrations(String id) =>
      _client.getList('/admin/tournaments/$id/race-registrations', _map);

  Future<JsonMap> approveRegistration(String id) =>
      _client.putObject('/admin/race-registrations/$id/approve', null, _map);

  Future<JsonMap> rejectRegistration(String id, String note) => _client
      .putObject('/admin/race-registrations/$id/reject', {'note': note}, _map);

  Future<JsonMap> updateRace(String id, JsonMap payload) =>
      _client.putObject('/admin/races/$id', payload, _map);

  Future<void> deleteRace(String id) => _client.delete('/admin/races/$id');

  Future<List<JsonMap>> getNews() => _client.getList('/admin/news', _map);

  Future<JsonMap> getNewsById(String id) =>
      _client.getObject('/admin/news/$id', _map);

  Future<JsonMap> createNews(JsonMap payload, {String? imagePath}) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return _client.multipartObject(
        'POST',
        '/admin/news',
        payload.map((key, value) => MapEntry(key, '$value')),
        {'image': imagePath},
        _map,
      );
    }
    return _client.postObject('/admin/news', payload, _map);
  }

  Future<JsonMap> updateNews(String id, JsonMap payload, {String? imagePath}) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return _client.multipartObject(
        'PUT',
        '/admin/news/$id',
        payload.map((key, value) => MapEntry(key, '$value')),
        {'image': imagePath},
        _map,
      );
    }
    return _client.putObject('/admin/news/$id', payload, _map);
  }

  Future<void> deleteNews(String id) => _client.delete('/admin/news/$id');

  Future<JsonMap> getWallet() => _client.getObject('/admin/wallet', _map);

  Future<List<JsonMap>> getWalletTransactions() =>
      _client.getList('/admin/wallet/transactions', _map);

  Future<List<JsonMap>> getWithdrawals() =>
      _client.getList('/admin/wallet/withdrawals', _map);

  Future<JsonMap> getWalletReconciliation() =>
      _client.getObject('/admin/wallet/reconciliation', _map);

  Future<JsonMap> approveWithdrawal(String id) =>
      _client.putObject('/admin/wallet/withdrawals/$id/approve', null, _map);

  Future<JsonMap> rejectWithdrawal(String id, String note) => _client.putObject(
    '/admin/wallet/withdrawals/$id/reject',
    {'note': note},
    _map,
  );

  Future<JsonMap> markWithdrawalPaid(String id) =>
      _client.putObject('/admin/wallet/withdrawals/$id/paid', null, _map);

  Future<JsonMap> getSystemSettings() =>
      _client.getObject('/admin/system-settings', _map);

  Future<JsonMap> updateSystemFees({
    required num defaultRegistrationFee,
    required num lateCheckInFee,
  }) => _client.putObject('/admin/system-settings/fees', {
    'defaultRegistrationFee': defaultRegistrationFee,
    'lateCheckInFee': lateCheckInFee,
  }, _map);

  Future<JsonMap> updateRaceDistances(List<int> distances) => _client.putObject(
    '/admin/system-settings/race-distances',
    {'distancesMeters': distances},
    _map,
  );

  Future<JsonMap> updateDefaultRules(String rules) => _client.putObject(
    '/admin/system-settings/rules',
    {'defaultTournamentRules': rules},
    _map,
  );

  Future<JsonMap> updateViolationTypes(List<JsonMap> types) =>
      _client.putObject('/admin/system-settings/violation-types', {
        'types': types,
      }, _map);

  Future<JsonMap> updateViolationRules(List<JsonMap> rules) =>
      _client.putObject('/admin/system-settings/violation-rules', {
        'rules': rules,
      }, _map);

  Future<JsonMap> getFinanceSettings() =>
      _client.getObject('/admin/finance-settings', _map);

  Future<JsonMap> updateFinanceSettings(JsonMap payload) =>
      _client.putObject('/admin/finance-settings', payload, _map);

  Future<List<JsonMap>> getProvinces() =>
      _client.getList('/admin/provinces', _map);

  Future<JsonMap> createProvince(JsonMap payload) =>
      _client.postObject('/admin/provinces', payload, _map);

  Future<JsonMap> updateProvince(String id, JsonMap payload) =>
      _client.putObject('/admin/provinces/$id', payload, _map);

  Future<void> deleteProvince(String id) =>
      _client.delete('/admin/provinces/$id');

  Future<JsonMap> setProvinceActive(String id, bool active) => _client
      .putObject('/admin/provinces/$id/active?active=$active', null, _map);

  Future<List<JsonMap>> getVenues(String provinceId) =>
      _client.getList('/admin/provinces/$provinceId/venues', _map);

  Future<JsonMap> createVenue(String provinceId, JsonMap payload) =>
      _client.postObject('/admin/provinces/$provinceId/venues', payload, _map);

  Future<JsonMap> updateVenue(String id, JsonMap payload) =>
      _client.putObject('/admin/venues/$id', payload, _map);

  Future<void> deleteVenue(String id) => _client.delete('/admin/venues/$id');

  Future<JsonMap> setVenueActive(String id, bool active) =>
      _client.putObject('/admin/venues/$id/active?active=$active', null, _map);

  Future<List<JsonMap>> getRefereeInvitations() =>
      _client.getList('/admin/referee-invitations', _map);

  Future<JsonMap> createRefereeInvitation(JsonMap payload) =>
      _client.postObject('/admin/referee-invitations', payload, _map);

  Future<JsonMap> cancelRefereeInvitation(String id) =>
      _client.putObject('/admin/referee-invitations/$id/cancel', null, _map);

  Future<List<JsonMap>> getRefereeSalaryConfigs() =>
      _client.getList('/admin/referee-salary-configs', _map);

  Future<JsonMap> createRefereeSalaryConfig(JsonMap payload) =>
      _client.postObject('/admin/referee-salary-configs', payload, _map);

  Future<JsonMap> updateRefereeSalaryConfig(String id, JsonMap payload) =>
      _client.putObject('/admin/referee-salary-configs/$id', payload, _map);

  Future<void> deleteRefereeSalaryConfig(String id) =>
      _client.delete('/admin/referee-salary-configs/$id');

  Future<List<JsonMap>> getBetMarkets() =>
      _client.getList('/admin/bet-markets', _map);

  Future<JsonMap> createBetMarket(String raceId, JsonMap payload) =>
      _client.postObject('/admin/races/$raceId/bet-market', payload, _map);

  Future<JsonMap> openBetMarket(String id) =>
      _client.putObject('/admin/bet-markets/$id/open', null, _map);

  Future<JsonMap> closeBetMarket(String id) =>
      _client.putObject('/admin/bet-markets/$id/close', null, _map);

  Future<JsonMap> settleBetMarket(String id) =>
      _client.putObject('/admin/bet-markets/$id/settle', null, _map);

  Future<List<JsonMap>> getMarketBets(String id) =>
      _client.getList('/admin/bet-markets/$id/bets', _map);
}
