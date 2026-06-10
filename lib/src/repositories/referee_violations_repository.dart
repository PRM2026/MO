import '../models/violation_record.dart';

class RefereeViolationsRepository {
  const RefereeViolationsRepository();

  Future<ViolationsPageData> fetchPageData() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return ViolationsPageData.sample();
  }
}
