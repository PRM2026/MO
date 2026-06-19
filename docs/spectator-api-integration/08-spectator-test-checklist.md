# Phase 08 - Spectator Test Checklist

## Muc tieu
- Dam bao spectator API integration khong fallback mock/hard-code.
- Dam bao public API khong gui token va auth API co gui token.
- Dam bao khong anh huong role khac.

## Service Tests
- Dung `MockClient` cho service spectator.
- Moi endpoint can test:
  - Success 2xx va `success: true`.
  - Empty list/data rong.
  - BE business error `success: false`.
  - Non-JSON response.
  - 401/403 voi API authenticated.
- Assert URL dung `baseUrl`.
- Assert public API khong co header `Authorization`.
- Assert `/auth/me` va password API co `Authorization: Bearer <token>`.

## Model Tests
- Parse tournament list/detail voi day du va optional missing fields.
- Parse race item/detail voi status, time, venue, participants, prizes.
- Parse race results voi rank, horse, jockey, owner optional, finish time/status.
- Parse horse/ranking neu endpoint co.
- Parse spectator profile tu `/auth/me`.

## ViewModel Tests
- Home:
  - loading -> success render data API.
  - API rong -> empty sections.
  - API loi -> `errorMessage`, khong mock.
- Races:
  - filters upcoming/finished/date dung voi data API.
  - detail load success/error.
- Results:
  - list result groups tu API.
  - race result empty -> empty state.
  - leaderboard retry khi loi.
- Profile:
  - load `/auth/me` success.
  - 401/403 expose error.
  - logout goi repository va route callback.

## Widget Tests
- `SpectatorHomeScreen`: loading, empty, error retry, success render featured/upcoming/results.
- `SpectatorRacesScreen`: filter, date filter, card tap mo detail callback.
- `SpectatorRaceDetailScreen`: success, no result, error retry.
- `SpectatorResultsScreen`: list, empty, error retry, leaderboard tap.
- `SpectatorProfileScreen`: loading, error retry, success profile, logout action.

## Regression Checklist
- Login role `SPECTATOR` vao `SpectatorShell`.
- Bottom nav spectator van chuyen dung 4 tab.
- Role `OWNER`, `JOCKEY`, `REFEREE`, `ADMIN` khong doi route/shell.
- Search production code:
  - Khong import `spectator_home_mock.dart`.
  - Khong import `spectator_races_mock.dart`.
  - Khong import `spectator_results_mock.dart`.
- Khong goi endpoint `/owner/...` trong spectator service/repository/viewmodel.

## Done Criteria
- Tat ca service/model/viewmodel tests spectator pass.
- Widget tests cho man chinh spectator pass.
- Manual test tren emulator voi BE local:
  - Home load API.
  - Races list/detail load API.
  - Results/leaderboard load API.
  - Profile/logout hoat dong.
