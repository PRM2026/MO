enum AssignedRaceFilter { all, upcoming, live, finished }

enum AssignedRaceStatus { live, ready, pendingResults, upcoming }

class AssignedRaceMeta {
  const AssignedRaceMeta({
    required this.location,
    required this.schedule,
    required this.lanes,
    required this.horses,
  });

  final String location;
  final String schedule;
  final String lanes;
  final String horses;
}

class AssignedRaceItem {
  const AssignedRaceItem({
    required this.raceCode,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.meta,
    required this.actionLabel,
    this.actionFilled = true,
    this.actionEnabled = true,
    this.actionSecondary = false,
    this.dimmed = false,
  });

  final String raceCode;
  final String title;
  final String imageUrl;
  final AssignedRaceStatus status;
  final AssignedRaceMeta meta;
  final String actionLabel;
  final bool actionFilled;
  final bool actionEnabled;
  final bool actionSecondary;
  final bool dimmed;

  String get statusLabel {
    switch (status) {
      case AssignedRaceStatus.live:
        return 'Đang đua';
      case AssignedRaceStatus.ready:
        return 'Sẵn sàng';
      case AssignedRaceStatus.pendingResults:
        return 'Chờ kết quả';
      case AssignedRaceStatus.upcoming:
        return 'Ngày mai';
    }
  }

  bool matchesFilter(AssignedRaceFilter filter) {
    switch (filter) {
      case AssignedRaceFilter.all:
        return true;
      case AssignedRaceFilter.upcoming:
        return status == AssignedRaceStatus.upcoming ||
            status == AssignedRaceStatus.ready;
      case AssignedRaceFilter.live:
        return status == AssignedRaceStatus.live;
      case AssignedRaceFilter.finished:
        return status == AssignedRaceStatus.pendingResults;
    }
  }
}

class AssignedRacesData {
  const AssignedRacesData({
    required this.races,
    this.profileImageUrl,
  });

  final List<AssignedRaceItem> races;
  final String? profileImageUrl;

  static AssignedRacesData sample() {
    return AssignedRacesData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBviQgH1BI_p3DaJsqvlWVFpKNvTm1rnu5UsamHrMVd6mA_7aezDBQT8rHtkiOfBdZRdEI6Pe8ErPW66QCeyw0fxLtbo7dejY2zjIjTYarkcXwYfAEGxtdhqvR233IM_kLrFMJwG6DLz-cAqQ52NAUMeiQpv6FIekW6q8kZGWuUv_j0NkvwdfT80SmR8kHUgAh1MmW9xedBM-W_cWIsbHTabjFaP_WHtcXkJBCsDxMV1j5RMWHLlNF7dLChXmyjNTvc39tmOAeJ4Hs',
      races: const [
        AssignedRaceItem(
          raceCode: 'Race #08',
          title: 'Grand Championship 2024',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAKY9o-G_a4JAxLlayaoIcUHng00zE5MvpyksVNi-_uK4KBmUMvfLMI3tPgXUaNsDOuW0whEG5uOaL0qEByhKI2pql3RLwPIamD_FKTF8KAcr0VfyZh3JNmVdtqRNTktV_54pGt9pvnCdUho24Uz4M8U1KXSLoxef8S6MkspfSV3-iN2OLWPKoHE2rSD9pCB5zivh9Aky_L74gwqHVUtv2zX3KHWe0efuFE6uniQWL96LEMgbDuSh6PAr9rSE8WEPDzmT6h0dyUTik',
          status: AssignedRaceStatus.live,
          meta: AssignedRaceMeta(
            location: 'Phú Thọ, HCM',
            schedule: '14:30 Today',
            lanes: '12 Làn chạy',
            horses: '24 Chiến mã',
          ),
          actionLabel: 'Mở điều hành',
        ),
        AssignedRaceItem(
          raceCode: 'Race #09',
          title: 'Cúp Ngựa Sắt Miền Đông',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBcJx3LyfqveS7dTdCcRpuhz8NONNyCAsWvFHNkr7nBc-A9QKnsA9OGIF8l3XaZE0QBizbdKnmXCZ4AEsSIsoaNzzb1D8-7klkQIY5OaUNQ8xRmdLgoMgRypNsTDXBnOO0g5ec-9H-Bgev3-whN2QB3k-osl2sZwpxK6FgJHRd3_StwYJKJ-bffldmDaxE_meZAwPpy5q1xfeTZCEsVAWOkf3OM6CZUmnoGyDplmxvR4XkN-T83BBGyRGpptTNDeQHUZ-RnRGEcfCk',
          status: AssignedRaceStatus.ready,
          meta: AssignedRaceMeta(
            location: 'Đại Nam, BD',
            schedule: '16:00 Today',
            lanes: '8 Làn chạy',
            horses: '16 Chiến mã',
          ),
          actionLabel: 'Mở điều hành',
          actionFilled: false,
        ),
        AssignedRaceItem(
          raceCode: 'Race #07',
          title: 'Vòng Loại Quốc Gia',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAsr1r2c1gan8TGjloEGoYRgqb5fy8mlP5V0X-1eD7rnYhDqwOCjvoqCk3MK4vn8HVbvTG1gQ0RLOU5MMcTKOfCyCRisEXlU6n678ZRpRY_bJsL2ekoMxb9TAAc5MixlUomW3ZelW7F8IC1JGeMZU94n07mFx_gBVh7gvO2H6t9dDyyTdLRNOmqaEmJzk-ZJS-l9Do-W8PBM5bIAvlmgpc8mTCPzQUqMA4qDTBwNGjL6Coq-KXiS4ntXItP0f1zWew5axg61ZgMX50',
          status: AssignedRaceStatus.pendingResults,
          meta: AssignedRaceMeta(
            location: 'Long An',
            schedule: '13:15 Done',
            lanes: '10 Làn chạy',
            horses: '20 Chiến mã',
          ),
          actionLabel: 'Xem chi tiết',
          actionFilled: false,
          actionSecondary: true,
        ),
        AssignedRaceItem(
          raceCode: 'Race #01',
          title: 'Hội Đua Xuân Giáp Thìn',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBgVP5EeYcP7rldZTlU0DJrZATgukwEgH6mBdAxdT6GvmSOQWzO22ZiaMm1fTrd4xBmgwkWuMastw4XKTO-kyG_LlxRavr5yR2Yr3VFf10WumJXaBrj4fTj7plM7bmd2qRMkkYO3SoEB-QeUOGwkYPe6WXQ5jt1hnS295nMkKtiV5uKHB2e2QIgvjH7CLx0WV0vJoXN6tiVmT4ESC5T028Z-Q7t_kOuDltZkxXAPThLtcDj0i7LO6I8OqrwtTLp-pkIKMb1JCjSAuw',
          status: AssignedRaceStatus.upcoming,
          meta: AssignedRaceMeta(
            location: 'Sóc Trăng',
            schedule: '08:00 Tomorrow',
            lanes: '12 Làn chạy',
            horses: '24 Chiến mã',
          ),
          actionLabel: 'Chưa mở',
          actionFilled: false,
          actionEnabled: false,
          dimmed: true,
        ),
      ],
    );
  }
}
