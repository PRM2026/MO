# Phase 06 - Spectator Profile And Account

## Muc tieu
- Profile spectator dung API/account data that.
- Bo fallback name/avatar tu mock.
- Giu logout hien co.
- Them doi mat khau neu portal spectator can account action nhu role khac.

## Endpoints
- `GET /auth/me` authenticated.
- `PUT /auth/password` authenticated neu them man doi mat khau.
- `GET /users/me/profile` va `PUT /users/me/profile` neu BE ho tro profile chi tiet.

## Model
- `SpectatorProfileData` gom:
  - `id`, `username`, `fullName`, `email`
  - `role`, `avatarUrl`, `phone` neu co
  - cac field profile public khac neu `/users/me/profile` tra ve
- Role label hien `SPECTATOR` hoac `Khan gia` theo design hien co.

## UI
- `SpectatorProfileScreen`:
  - Load `/auth/me` khi vao man.
  - Loading lan dau dung spinner.
  - Loi API hien message + nut `Thu lai`.
  - Neu avatar rong: dung `ProfileAvatar` fallback icon, khong dung `SpectatorHomeMock.defaultProfileImageUrl`.
  - Logout clear storage va ve public home nhu hien tai.
- Account actions:
  - `Doi mat khau` neu implement endpoint password.
  - `Dang xuat`.

## Error Handling
- 401/403: hien message phien dang nhap het han va action dang nhap lai neu can.
- `/auth/me` loi: khong doc mock; co the doc local profile chi de hien tam cached info neu da co, nhung phai kem error/retry.
- Logout loi storage hiem gap: van co gang route ve public home neu local clear thanh cong.

## Acceptance Criteria
- Profile khong import `spectator_home_mock.dart`.
- Profile avatar/name khong dung URL/name mock.
- Logout behavior khong doi.
- Neu them doi mat khau, submit loi/thanh cong hien feedback va khong anh huong role khac.
