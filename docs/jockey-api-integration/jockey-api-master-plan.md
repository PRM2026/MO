# Jockey API Integration Master Plan

## 1. Muc tieu tong the

Tai lieu nay chia jockey API integration thanh 16 phase nho de de code, review va verify. Scope chi gom role `JOCKEY` trong MO: Dashboard, Schedule, Horses/Assignments, Invitations, Results, Profile, Wallet va Notifications.

Nguyen tac chung:

- Khong sua BE.
- Khong lam thay doi flow cua `OWNER`, `REFEREE`, `SPECTATOR`, `ADMIN`.
- Giu `ApiConfig.baseUrl` hien tai.
- Dung `ApiClient` hien co.
- Runtime jockey khong fallback `.sample()` khi API loi.
- Khong bịa endpoint moi; neu BE khong co endpoint, spec phai map tu endpoint hien co.

## 2. Danh sach phase moi

1. `01-jockey-api-client-and-errors.md` - chuan hoa service dung `ApiClient`, error handling.
2. `02-jockey-viewmodel-ui-state.md` - chuan hoa loading/empty/error/retry, bo sample fallback.
3. `03-jockey-dashboard-api.md` - dashboard overview tu `/jockey/dashboard`.
4. `04-jockey-dashboard-performance.md` - KPI/performance tu `/jockey/performance`.
5. `05-jockey-profile-read.md` - doc profile tu `/jockey/profile`.
6. `06-jockey-profile-update.md` - update multipart profile.
7. `07-jockey-invitations-list-detail.md` - list/detail loi moi.
8. `08-jockey-invitations-actions.md` - accept/reject loi moi.
9. `09-jockey-schedule-list-calendar.md` - lich dua tu `/jockey/races`.
10. `10-jockey-race-detail-results.md` - detail race va results read-only.
11. `11-jockey-horse-assignments.md` - ngua/assignment map tu invitations/races/profile.
12. `12-jockey-results-performance-prizes.md` - ket qua, performance, prize payout.
13. `13-jockey-wallet.md` - wallet, transactions, deposit, withdrawal.
14. `14-jockey-notifications.md` - notifications, unread count, mark read.
15. `15-jockey-navigation-polish.md` - navigation, quick links, UI consistency.
16. `16-jockey-test-checklist.md` - unit/widget/manual/regression tests.

## 3. Done Criteria Tong

- Tat ca jockey screens dung API that hoac empty/error state that.
- Khong con `.sample()` trong catch runtime cua jockey ViewModel.
- Khong co endpoint moi duoc bịa trong mobile.
- Jockey flow khong goi endpoint owner/referee/admin.
- Manual flow jockey pass tren emulator voi BE local.
