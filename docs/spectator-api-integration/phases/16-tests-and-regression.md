# Phase 16 - Tests And Regression

## Muc tieu
- Dam bao spectator API integration dung contract va khong anh huong role khac.

## Service Tests
- Success 2xx va `success: true`.
- Empty list/data.
- BE business error `success: false`.
- Non-JSON response.
- 401/403 cho API authenticated.
- Public API khong gui `Authorization`.
- Auth API gui bearer token.

## Model/ViewModel Tests
- Parse tournament/race/result/horse/profile day du va optional missing.
- Home loading -> success/empty/error.
- Races filters upcoming/finished/date.
- Race detail success/error.
- Results list va leaderboard empty/error.
- Profile success/401/logout.

## Widget Tests
- Home, Races, Race Detail, Results, Leaderboard, Profile.
- Moi man co loading, empty, error + retry, success render.

## Regression Checklist
- Login role `SPECTATOR` vao `SpectatorShell`.
- Role khac van vao shell cu.
- Production spectator code khong import:
  - `spectator_home_mock.dart`
  - `spectator_races_mock.dart`
  - `spectator_results_mock.dart`
- Spectator code khong goi `/owner/...`.

## Done Criteria
- Tests spectator pass.
- Manual flow voi BE local pass cho Home, Races, Detail, Results, Profile.
