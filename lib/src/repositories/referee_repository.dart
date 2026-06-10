import '../models/referee_dashboard_data.dart';

class RefereeRepository {
  const RefereeRepository();

  Future<RefereeDashboardData> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return RefereeDashboardData.sample();
  }
}
