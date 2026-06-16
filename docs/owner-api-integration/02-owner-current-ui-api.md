# Phase 02 - Owner Current UI API

## Muc tieu
- Noi API that cho 4 tab owner hien co: Dashboard, Tournaments, Horses, Profile.
- Giu layout/navigation owner hien co.
- Loai bo fallback sample trong runtime owner.

## Dashboard
- Screen: `OwnerDashboardScreen`.
- ViewModel: `OwnerDashboardViewModel`.
- Repository/service hien co:
  - `OwnerDashboardRepository`
  - `OwnerDashboardService`
  - `OwnerHorseService`
  - `AuthRepository`
- Endpoint:
  - `GET /owner/dashboard` authenticated
  - `GET /tournaments` public
  - `GET /owner/horses` authenticated
  - `GET /auth/me` authenticated
- Data mapping:
  - Hero tournament: chon tournament co status `OPEN_REGISTRATION`, `PUBLISHED`, `ONGOING`; neu khong co thi dung tournament gan nhat.
  - Featured horses: lay tu `/owner/horses`, toi da 6 horse.
  - Upcoming races: lay tu `DashboardResponse.upcoming`.
  - Profile image: lay tu `/auth/me.avatarUrl`.
- Can sua:
  - `OwnerDashboardRepository.fetchDashboard()` khong return `OwnerDashboardData.sample()` khi API loi.
  - `OwnerDashboardViewModel` expose `errorMessage`.
  - `OwnerDashboardScreen` hien error + retry neu dashboard load fail.

## Tournaments
- Screens:
  - `OwnerTournamentsScreen`
  - `OwnerTournamentDetailScreen`
- Endpoint:
  - `GET /tournaments`
  - `GET /tournaments/{id}`
- List filters:
  - `all`: tat ca
  - `upcoming`: khong phai `ONGOING`, khong `COMPLETED`, khong `CANCELLED`
  - `ongoing`: `ONGOING`
  - `completed`: `COMPLETED` hoac `CANCELLED`
- Can sua:
  - Khong dung `TournamentListItem.sampleData()` trong owner flow.
  - Neu API loi: hien message `Không thể tải giải đấu.` va nut retry.
  - Detail loi: giu error state hien co, khong fallback.

## Horses
- Screen: `OwnerHorsesScreen`.
- Endpoint:
  - `GET /owner/horses`
- Model:
  - `HorseResponse` -> `OwnerHorseItem`
  - Fields: `id`, `name`, `breed`, `age`, `gender`, `color`, `heightCm`, `weightKg`, `imageUrl`, `documentUrl`, `status`, `reviewReason`, `performance`, `raceHistory`.
- Can sua:
  - Danh sach empty that khi BE tra rong.
  - Search/filter chi lam tren data API.
  - Nut add horse khong toast `đang phát triển` sau phase 03; tam thoi phase 02 co the giu nhung phai ghi TODO ro.

## Profile
- Screen: `OwnerProfileScreen`.
- Endpoint:
  - `GET /auth/me`
  - `GET /users/me/profile` neu can thong tin profile chi tiet
  - `PUT /users/me/profile` JSON hoac multipart cho update sau
  - `PUT /auth/password` cho doi mat khau
- Can sua:
  - Khong dung `RefereeProfileData` lam model runtime lau dai cho owner. Tao model owner profile rieng hoac user profile adapter rieng.
  - Neu `/auth/me` loi: hien error + retry, khong tao fake `OWN-000`.
  - Logout tiep tuc clear local storage va quay ve login.

## Acceptance Criteria
- Login owner vao 4 tab khong thay data sample cu neu BE rong.
- Tat ca loi API trong 4 tab hien error state.
- Pull-to-refresh goi API that.
- Khong co thay doi hanh vi cac role khac.
