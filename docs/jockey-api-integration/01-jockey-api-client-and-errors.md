# Phase 01 - Jockey API Client And Errors

## Muc tieu
- Dung `ApiClient` hien co cho toan bo service jockey.
- Bo cac service jockey decode JSON thu cong.
- Dam bao moi API authenticated co bearer token tu `AuthStorage`.

## Viec can lam
- Refactor `JockeyInvitationService` sang `ApiClient`.
- Tao service skeleton cho:
  - `JockeyDashboardService`
  - `JockeyProfileService`
  - `JockeyRaceService`
  - `JockeyWalletService`
  - `JockeyNotificationService`
- Moi service nhan `ApiClient? apiClient`, `http.Client? client`, `String? baseUrl`, `AuthStorage? storage`.
- Neu khong inject `apiClient`, tao `ApiClient(client: client, baseUrl: baseUrl, storage: storage)`.

## Error Policy
- Dung `ApiException`.
- Token rong, 401/403, validation error, non-JSON phai di len ViewModel.
- Khong catch loi trong service de tra object fake.

## Acceptance Criteria
- Jockey services test duoc bang `MockClient`.
- Header `Authorization` duoc gui voi API jockey.
- Khong con duplicate JSON decode logic trong service jockey moi/refactor.
