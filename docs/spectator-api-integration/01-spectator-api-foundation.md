# Phase 01 - Spectator API Foundation

## Muc tieu
- Chuan hoa nen tang goi API cho spectator portal trong MO.
- Bo runtime hard-code/mock cua role `SPECTATOR`.
- Giu `ApiConfig.baseUrl` hien tai, khong them `.env`, `dart-define`, hay dependency config moi.
- Public API cua spectator phai goi voi `authenticated: false`; API tai khoan/profile phai dung token tu `AuthStorage`.

## Pham vi
- Chi ap dung cho role `SPECTATOR`.
- Khong sua flow cua `OWNER`, `JOCKEY`, `REFEREE`, `ADMIN`.
- Khong sua BE trong phase nay.
- Khong dung endpoint owner-only nhu `/owner/dashboard`, `/owner/horses`, `/owner/races`, `/owner/prizes`.

## Service/Repository Spec
- Tao service rieng cho spectator, khuyen nghi `SpectatorApiService`.
- Service dung `ApiClient` hien co tai `lib/src/services/api_client.dart`.
- Constructor cho phep inject `ApiClient?`, `http.Client?`, `baseUrl`, `AuthStorage?` de test.
- Public data methods phai goi:
  - `getList(..., authenticated: false)`
  - `getObject(..., authenticated: false)`
- Profile/account methods phai goi authenticated mac dinh.
- Repository khong catch loi roi tra mock/sample; loi phai bubble len ViewModel.

## Model Spec
- Tao model rieng neu UI spectator can data khac owner:
  - `SpectatorHomeData`
  - `SpectatorRaceItem`
  - `SpectatorRaceDetail`
  - `SpectatorResultGroup`
  - `SpectatorProfileData`
- Co the tai su dung/adapt `TournamentListItem` va `OwnerTournamentDetail` cho public tournament trong phase dau.
- Neu tai su dung model owner, khong import widget/viewmodel owner vao spectator flow.

## ViewModel State Standard
- Moi spectator ViewModel co toi thieu:
  - `bool isLoading`
  - `String? errorMessage`
  - data nullable hoac list rong that
- Refresh/retry phai goi lai API that.
- Khong set data tu `SpectatorHomeMock`, `SpectatorRacesMock`, `SpectatorResultsMock` trong `catch`.

## UI State Standard
- Loading lan dau: `CircularProgressIndicator`.
- Empty state: text ro theo context.
- Error state: message BE hoac fallback message + nut `Thu lai`.
- Pull-to-refresh neu man da co scroll/list.
- Khong hien toast placeholder cho action dieu huong; action phai mo man that hoac disable ro rang.

## Acceptance Criteria
- Production spectator screen khong import `lib/src/data/spectator_*_mock.dart`.
- Public spectator API khong gui `Authorization`.
- Auth/profile spectator API co gui `Authorization`.
- Loi API khong bi che boi mock/sample.
- Khong co thay doi navigation cua role khac.
