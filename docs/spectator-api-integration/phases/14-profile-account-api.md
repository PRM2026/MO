# Phase 14 - Profile Account API

## Muc tieu
- Profile spectator dung API/account data that.
- Bo mock fallback trong Profile tab.

## Endpoints
- `GET /auth/me`
- `PUT /auth/password` neu them doi mat khau.
- `GET /users/me/profile` neu BE co profile chi tiet.

## UI
- `SpectatorProfileScreen` load profile qua ViewModel.
- Loading lan dau dung spinner.
- Error hien message + `Thu lai`.
- Avatar rong dung fallback icon.
- Logout giu behavior hien co.
- Them action doi mat khau neu implement endpoint.

## Acceptance Criteria
- Profile khong import `spectator_home_mock.dart`.
- Khong hien avatar URL mock.
- Logout van clear local storage va ve public home.
