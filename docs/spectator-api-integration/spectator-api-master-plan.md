# Spectator API Integration Master Plan

## 1. Muc tieu tong the

Tai lieu nay gom cac plan trien khai spectator API integration tu Phase 01 den Phase 08. Muc tieu la chia nho tung spec de de code, review va verify theo tung buoc.

Nguyen tac chung:

- Chi ap dung cho role `SPECTATOR` trong MO.
- Khong sua BE trong cac phase nay.
- Khong lam thay doi flow cua `OWNER`, `JOCKEY`, `REFEREE`, `ADMIN`.
- Giu `ApiConfig.baseUrl` hien tai; khong them `.env`, `dart-define`, hay dependency config moi.
- Public spectator API phai goi voi `authenticated: false`.
- Profile/account API phai lay token tu `AuthStorage` va gui `Authorization: Bearer <token>`.
- Runtime spectator khong fallback sang mock/hard-code khi API loi; UI phai hien loading, empty, error va retry that.
- Khong goi endpoint owner-only nhu `/owner/dashboard`, `/owner/horses`, `/owner/races`, `/owner/prizes`.

## 2. Phase 01 - Spectator API Foundation

Muc tieu: chuan hoa nen tang goi API cho spectator portal, gom service/repository/viewmodel state va quy tac public/auth API.

- Tao service spectator dung `ApiClient`.
- Public methods goi `getList/getObject` voi `authenticated: false`.
- Profile/account methods dung token.
- Tao model rieng khi can: `SpectatorHomeData`, `SpectatorRaceItem`, `SpectatorRaceDetail`, `SpectatorResultGroup`, `SpectatorProfileData`.
- Repository khong catch loi roi tra mock/sample.
- Moi ViewModel co `isLoading`, `errorMessage`, data nullable/list rong, retry that.
- Production spectator screen khong import `lib/src/data/spectator_*_mock.dart`.

## 3. Phase 02 - Spectator Home API

Muc tieu: thay `SpectatorHomeMock` bang API that cho Home tab, giu layout hien co.

- Endpoints uu tien:
  - `GET /tournaments`
  - `GET /tournaments/{id}`
  - `GET /races/{id}/results`
  - Public race list/detail neu BE co.
  - Public horse/ranking neu BE co.
- Featured event chon tu tournament public theo status `OPEN_REGISTRATION`, `PUBLISHED`, `ONGOING`, hoac tournament sap toi gan nhat.
- Upcoming races lay tu public race list hoac races trong tournament detail.
- Featured horses lay tu public horse ranking; neu chua co endpoint thi hien empty state.
- Recent results lay tu race da co ket qua va `/races/{id}/results`.
- Profile app bar lay `/auth/me` neu user dang login, khong dung mock avatar URL.

## 4. Phase 03 - Spectator Races List And Detail

Muc tieu: thay `SpectatorRacesMock`, hoan thien list/filter va them race detail.

- Endpoints:
  - `GET /races`
  - `GET /races/{id}`
  - fallback `GET /tournaments` va `GET /tournaments/{id}` neu BE chua co race list public.
  - `GET /races/{id}/results` cho detail.
- `SpectatorRacesScreen` filter upcoming/finished/date tren data API.
- Date picker khong hard-code nam 2026.
- Them `SpectatorRaceDetailScreen` hien race info, tournament, venue, distance, time, status, participants, prizes va action xem ket qua.
- Tap race card mo detail that, khong toast placeholder.

## 5. Phase 04 - Spectator Results And Leaderboard

Muc tieu: thay `SpectatorResultsMock`, keo result/leaderboard that.

- Endpoints:
  - `GET /races/{id}/results`
  - Public race list/detail neu BE co.
  - fallback tournament detail neu can.
- Results tab lay races da co result, goi result API va hien group cards.
- Them man/detail leaderboard cho mot race.
- Finisher hien rank, horse, jockey, owner optional, finish time/status.
- Neu BE khong co category cu, doi filter sang all/recent/verified trong phase polish.
- Leaderboard action mo man that, khong toast placeholder.

## 6. Phase 05 - Spectator Tournaments And Horses

Muc tieu: keo full public tournament data va horse/ranking data cho spectator.

- Endpoints:
  - `GET /tournaments`
  - `GET /tournaments/{id}`
  - public horse/ranking neu co: `GET /horses`, `GET /horses/{id}`, `GET /horses/rankings`.
- Khong dung `TournamentRepository.fetchTournaments()` neu method con fallback sample.
- Co the adapter `OwnerTournamentDetail` trong phase dau, nhung nen tao naming spectator rieng cho code moi.
- Tournament detail hien info, rules, races va prizes neu public.
- Horse/ranking neu BE chua co thi UI empty state va TODO endpoint ro, khong hard-code data.

## 7. Phase 06 - Spectator Profile And Account

Muc tieu: profile spectator dung API/account data that, bo fallback mock.

- Endpoints:
  - `GET /auth/me`
  - `PUT /auth/password` neu them doi mat khau.
  - `GET /users/me/profile` va `PUT /users/me/profile` neu BE ho tro profile chi tiet.
- `SpectatorProfileScreen` load `/auth/me`, hien loading/error/retry.
- Avatar rong dung fallback icon cua `ProfileAvatar`, khong dung URL mock.
- Logout giu behavior hien co: clear local storage va ve public home.
- Neu them doi mat khau, route/action phai rieng cho spectator va khong anh huong role khac.

## 8. Phase 07 - Spectator UI Gap Polish

Muc tieu: hoan thien UI state va navigation sau khi keo API.

- Them loading/empty/error/retry cho Home, Races, Results, Profile va cac detail moi.
- Xoa toast placeholder cho action chinh.
- Hero/detail action mo tournament/race detail that.
- Promo VIP chi giu neu co flow that; neu chua co thi an.
- Anh rong/sai URL dung fallback noi bo.
- Them routes spectator rieng cho race detail, race results, tournament detail, horse/ranking neu implement.

## 9. Phase 08 - Spectator Test Checklist

Muc tieu: dam bao spectator API integration khong fallback mock va khong anh huong role khac.

- Service tests voi `MockClient` cho success, empty, BE error, non-JSON, 401/403.
- Assert public API khong gui `Authorization`; auth API co bearer token.
- Model tests cho tournament, race, result, horse/ranking, profile.
- ViewModel tests cho loading -> success, empty, error, retry, filters.
- Widget tests cho Home, Races, Race Detail, Results, Profile.
- Regression:
  - Login `SPECTATOR` vao `SpectatorShell`.
  - Role khac van vao shell cu.
  - Production spectator code khong import `spectator_*_mock.dart`.
  - Spectator code khong goi endpoint `/owner/...`.

## Done Criteria

- Tat ca spec phase co file rieng trong `docs/spectator-api-integration/`.
- Implement theo spec se loai bo runtime hard-code/mock cua spectator.
- Test service/model/viewmodel/widget spectator pass.
- Manual flow spectator chay duoc voi BE local.
