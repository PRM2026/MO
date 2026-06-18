# Phase 16 - Jockey Test Checklist

## Unit Tests - Services
- Moi service dung `MockClient`.
- Case:
  - success 2xx
  - BE `success:false`
  - 401/403
  - validation error map
  - non-JSON
  - empty list
- Assert URL, header `Accept`, header bearer token, body JSON/multipart.

## Unit Tests - Models
- Jockey profile.
- Jockey invitation.
- Race.
- Race result.
- Jockey performance.
- Wallet/transaction/deposit/withdrawal.
- Notification page.

## ViewModel Tests
- API success -> data populated.
- API loi -> error, data null/list empty, khong sample.
- Empty list -> empty state.
- Accept/reject reload list/detail.
- Profile update reload profile.
- Wallet deposit/withdraw success.
- Mark notification read update count.

## Widget Tests
- Loading.
- Empty.
- Error + retry.
- Success render.
- Form validation.
- Submit busy state.
- Submit error/success feedback.

## Manual Test
- Login role `JOCKEY`.
- Dashboard.
- Profile read/update.
- Invitations list/detail/accept/reject.
- Schedule calendar/list.
- Race detail/results.
- Horses/assignments.
- Results/performance/prizes.
- Wallet deposit/withdraw.
- Notifications mark read/all.

## Regression
- Role `OWNER`, `REFEREE`, `SPECTATOR`, `ADMIN` khong doi behavior.
- Jockey UI khong goi owner/referee/admin endpoints.

## Phase 16 Verification Runbook
- Chay `flutter analyze`.
- Chay `flutter test` day du, khong exclude `test/widget_test.dart`.
- Neu fail, phan loai:
  - Fail do Jockey phase 1-15: sua test/code trong phase 16.
  - Fail do role khac bi regression: revert/sua ngay vi ngoai scope.
  - Fail do moi truong/BE/manual-only: ghi chu ro command, error va ly do.
- Manual smoke voi BE local:
  - Login role `JOCKEY`.
  - Di qua dashboard, profile read/update, invitations list/detail/accept/reject.
  - Di qua schedule, race detail/results, horses/assignments.
  - Di qua results/performance/prizes, wallet deposit/withdraw, notifications mark read/all.
  - Smoke nhanh owner/referee/spectator de xac nhan route va bottom nav khong doi.
