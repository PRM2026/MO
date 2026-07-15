# Phase 01 - Foundation Service Contract

## Muc tieu
- Tao nen tang API rieng cho spectator.
- Dung `ApiClient` hien co, khong tao client moi neu khong can.

## Can code
- Tao `SpectatorApiService` hoac cac service nho theo domain neu code dai.
- Constructor cho phep inject `ApiClient?`, `http.Client?`, `baseUrl`, `AuthStorage?`.
- Public methods mac dinh goi `authenticated: false`.
- Auth/account methods goi authenticated mac dinh.
- Repository khong catch loi roi tra mock/sample.

## Endpoints nen ho tro truoc
- `GET /tournaments`
- `GET /tournaments/{id}`
- `GET /races/{id}/results`
- `GET /auth/me`

## Acceptance Criteria
- Public API request khong co `Authorization`.
- Auth API request co `Authorization: Bearer <token>`.
- Loi API bubble len ViewModel.
- Khong import `spectator_*_mock.dart`.
