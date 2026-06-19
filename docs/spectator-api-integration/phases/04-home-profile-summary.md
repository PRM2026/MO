# Phase 04 - Home Profile Summary

## Muc tieu
- App bar Home dung profile that neu user dang login.
- Bo fallback avatar URL tu `SpectatorHomeMock`.

## Can code
- `SpectatorHomeScreen` load profile summary qua ViewModel/repository.
- Goi `GET /auth/me` khi co token/session.
- Neu chua login hoac token loi, hien display name generic `Khan gia`.
- Avatar rong dung fallback icon/local visual cua component, khong dung network mock URL.

## Edge Cases
- `/auth/me` 401/403: khong crash Home public.
- Local profile cache co the hien tam, nhung phai khong che loi API neu user dang o Profile screen.

## Acceptance Criteria
- Home khong import `spectator_home_mock.dart`.
- App bar khong dung mock avatar.
- Role khac khong doi.
