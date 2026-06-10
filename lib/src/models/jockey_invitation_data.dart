class JockeyInvitationListItem {
  const JockeyInvitationListItem({
    required this.id,
    required this.horseName,
    required this.tournamentName,
    required this.ownerName,
    required this.raceDate,
    required this.baseFee,
    this.horseImageUrl,
    this.isNew = false,
  });

  final String id;
  final String horseName;
  final String tournamentName;
  final String ownerName;
  final String raceDate;
  final String baseFee;
  final String? horseImageUrl;
  final bool isNew;
}

class JockeyInvitationDetail {
  const JockeyInvitationDetail({
    required this.id,
    required this.horseName,
    required this.horseBreed,
    required this.tournamentBadge,
    required this.horseImageUrl,
    required this.ownerName,
    required this.ownerSubtitle,
    required this.ownerMessage,
    required this.scheduleWarning,
    required this.conflictEventName,
    required this.baseFee,
    required this.prizeShareLabel,
    required this.prizeShareDescription,
    required this.raceDate,
    required this.startTime,
    required this.venue,
    this.profileImageUrl,
  });

  final String id;
  final String horseName;
  final String horseBreed;
  final String tournamentBadge;
  final String horseImageUrl;
  final String ownerName;
  final String ownerSubtitle;
  final String ownerMessage;
  final String scheduleWarning;
  final String conflictEventName;
  final String baseFee;
  final String prizeShareLabel;
  final String prizeShareDescription;
  final String raceDate;
  final String startTime;
  final String venue;
  final String? profileImageUrl;

  static JockeyInvitationDetail sample({String? profileImageUrl}) {
    return JockeyInvitationDetail(
      id: 'inv-001',
      profileImageUrl: profileImageUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCWdD3Nr2ldgjHkj_bG93k0NgUoOQoOqFwzRJ143IGVi8yuQh1ar3ydoAYCOEPbHaaeaSWSPLQVggMzqs4GeLWf-1wxe_sM3kpWiz3bKlXfrvM0QCpFLNN9wI5Mxui564oeKdZ3h-nWJL6ywleXnBiYCL0YFm9hdAO2viw0sxVeD0b25oyAZNAsGsL_5buu59ycrgT0raXVOe2cuf-nBoFe6vXfdf5IkbYESynzBNWRY0H0wzDMFezyvfeIbESDJV_JkhDFA4CU2es',
      horseName: 'Tuyết Ảnh',
      horseBreed: 'Giống loài: Thoroughbred (Thuần chủng)',
      tournamentBadge: 'Elite Sprint Cup',
      horseImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDeey72OO2gfDOyWxuJprAebRXTljtz_pKueSY9TTYcw-nL8R6D6La-BTGtCq9lAwQnYVWYcG1t7D-jWCoZXxocwgzEQn_ReG8sJac_7ef105XQ72aegL90s2MOYmIRD8J-dp1K8N20DN5mAvxPfkE9Ntqh5j1Iwrdn950ixB9p3JeK01MFtxMkIGmmV-7VbUd61Iv6agcQte2msjF9sbnGqXoJRJVkl3V5jeOa9zFtuBqhqbLAwSAPu1Q4sEE5P4C-zeXxQ_IkoYU',
      ownerName: 'Royal Elite Stables',
      ownerSubtitle: 'Chủ sở hữu chuyên nghiệp • Hạng Platinum',
      ownerMessage:
          'Chúng tôi rất ấn tượng với phong độ của bạn trong các giải đấu gần đây. Tuyết Ảnh cần một nài ngựa có bản lĩnh và tốc độ như bạn để chinh phục Cup Elite lần này.',
      scheduleWarning:
          'Lưu ý: Trùng lịch với giải đấu Coastal Classic (cách nhau 2 giờ). Vui lòng kiểm tra lộ trình di chuyển.',
      conflictEventName: 'Coastal Classic',
      baseFee: '10.000.000',
      prizeShareLabel: '+ 10% Prize Share',
      prizeShareDescription: 'Chia sẻ từ quỹ tiền thưởng thắng giải',
      raceDate: '24 Th05, 2024',
      startTime: '15:30',
      venue: 'Grand National',
    );
  }

  static List<JockeyInvitationListItem> sampleList() {
    return const [
      JockeyInvitationListItem(
        id: 'inv-001',
        horseName: 'Tuyết Ảnh',
        tournamentName: 'Elite Sprint Cup',
        ownerName: 'Royal Elite Stables',
        raceDate: '24 Th05, 2024',
        baseFee: '10.000.000 VND',
        isNew: true,
        horseImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDeey72OO2gfDOyWxuJprAebRXTljtz_pKueSY9TTYcw-nL8R6D6La-BTGtCq9lAwQnYVWYcG1t7D-jWCoZXxocwgzEQn_ReG8sJac_7ef105XQ72aegL90s2MOYmIRD8J-dp1K8N20DN5mAvxPfkE9Ntqh5j1Iwrdn950ixB9p3JeK01MFtxMkIGmmV-7VbUd61Iv6agcQte2msjF9sbnGqXoJRJVkl3V5jeOa9zFtuBqhqbLAwSAPu1Q4sEE5P4C-zeXxQ_IkoYU',
      ),
      JockeyInvitationListItem(
        id: 'inv-002',
        horseName: 'Hắc Phong',
        tournamentName: 'Vietnam Derby Cup',
        ownerName: 'Saigon Racing Club',
        raceDate: '02 Th06, 2024',
        baseFee: '8.500.000 VND',
        horseImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDtiNPBWozvysd2Bfd0fDdNXqmLgNcuDTB5HFa50RgUYoyA95jSzzAPn5LDpVHIevC3cT9LSEh-NWDfh-kjOQcX02VcTc4XnnMQupKWb-z4dp95_f2TQRRcyS020zyT34d2mCiCfo5Zfpouy7MBilM3ebXlE0TfMVoxNv0UQvgGMqjyeHwIZfLT3QjblGhLr0LTlGob0NbN_mPkbajM2KGV6vTJuMtejftQuOlRpOAV5j0XYs-rFXmiOPVNwDqh0nQV9zmRdKTI7Z4',
      ),
    ];
  }
}
