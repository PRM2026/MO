# Phase 08 - Owner Test Checklist

## Muc tieu
- Dam bao owner API integration khong bi fallback sample va khong anh huong role khac.
- Test theo tung phase de de code va verify.

## Unit Tests - Services
- Dung `MockClient` cho moi service owner.
- Case can co cho moi endpoint:
  - Success 2xx, `success: true`
  - BE business error, `success: false`
  - 401/403
  - Validation error map trong `data`
  - Non-JSON response
  - Empty list
- Service phai assert:
  - URL dung `baseUrl`
  - Header `Accept: application/json`
  - Header `Authorization` co bearer token voi API authenticated
  - Body JSON/multipart dung field BE yeu cau

## Unit Tests - Models
- Parse `HorseResponse` day du va thieu optional fields.
- Parse `DashboardResponse` voi `wallet`, `upcoming`, `recentTransactions`, `recentNotifications`.
- Parse `JockeyInvitationResponse`.
- Parse `EligibleHorseTeamResponse`.
- Parse `RaceRegistrationResponse`.
- Parse `RaceComplaintResponse`.
- Parse `WalletResponse`, `WalletTransactionResponse`.
- Parse notification page response co `content`.

## ViewModel Tests
- Dashboard:
  - Loading -> data success.
  - API loi -> `errorMessage` co gia tri, `data == null`, khong sample.
- Horses:
  - API rong -> list rong, khong error.
  - API loi -> error, list rong.
  - Search/filter chay tren data API.
- Tournament:
  - Filters dung status.
  - Detail loi -> error state.
- Horse CRUD:
  - Submit success reload list.
  - Submit validation loi expose message.
- Invitations:
  - Create success reload list/detail.
  - Cancel success update status.
- Registration:
  - No eligible teams -> empty state.
  - Register success tao response.
  - Withdraw success update status.
- Wallet/Notifications:
  - Deposit/withdraw success.
  - Mark read update unread count.

## Widget Tests
- Moi screen owner chinh can test:
  - Initial loading.
  - Empty state.
  - Error state + retry button.
  - Success state render item/data.
- Form screens:
  - Required validation.
  - Submit disabled khi invalid/busy.
  - Submit success hien feedback.
  - Submit error hien message.

## Manual Test - Android Emulator
- Chay BE local port 8080.
- Chay MO:
  - `flutter pub get`
  - `flutter run`
- Dang nhap tai khoan role `OWNER`.
- Checklist:
  - Dashboard load API, khong hien sample cu khi BE rong.
  - Tournament list/detail load API.
  - Horse list load API.
  - Tao horse moi, status pending.
  - Xem horse detail.
  - Sua horse.
  - Xoa horse neu BE cho phep.
  - Moi jockey cho horse/race.
  - Xem invitation list/detail.
  - Huy pending invitation.
  - Xem accepted jockeys.
  - Dang ky race bang eligible horse team.
  - Xem registrations.
  - Rut pending registration.
  - Xem owner races.
  - Xem race results.
  - Tao complaint.
  - Xem complaint list.
  - Xem wallet.
  - Tao deposit order.
  - Tao withdrawal request.
  - Xem notifications.
  - Mark notification read.
  - Mark all read.

## Regression Checklist
- Login/navigation role owner van vao `OwnerShell`.
- Role khac van vao shell cu cua ho.
- `ApiConfig.baseUrl` van giu logic hien tai:
  - Web: `localhost`
  - Android emulator: `10.0.2.2`
  - iOS/desktop: `localhost`
- Khong sua BE.
- Khong commit/generated churn ngoai scope owner neu khong can.

## Done Criteria
- Tat ca service tests owner pass.
- Tat ca model parsing tests pass.
- Owner ViewModel tests khang dinh khong fallback sample khi API loi.
- Manual flow owner chay duoc tren emulator voi BE local.
