# Phase 01 - Owner API Foundation

## Muc tieu
- Chuan hoa nen tang goi API cho owner portal trong MO.
- Giu `ApiConfig.baseUrl` hien tai, khong them `dart-define`, `.env`, hay dependency moi cho config.
- Tat ca API can dang nhap phai dung token tu `AuthStorage` va header `Authorization: Bearer <token>`.
- Bo viec fallback sang `.sample()` trong runtime owner khi API loi; UI phai hien loading, empty, error, retry that.

## Pham vi
- Chi ap dung cho code trong owner portal va service/model owner dung chung.
- Khong sua flow cua `JOCKEY`, `REFEREE`, `SPECTATOR`, `ADMIN`.
- Khong sua BE trong phase nay.

## API Client Spec
- Tao helper dung chung, khuyen nghi file `lib/src/services/api_client.dart`.
- Constructor nhan:
  - `http.Client? client`
  - `String? baseUrl`
  - `AuthStorage? storage`
- Gia tri mac dinh:
  - `_client = client ?? http.Client()`
  - `_baseUrl = baseUrl ?? ApiConfig.baseUrl`
  - `_storage = storage ?? AuthStorage()`
- Cac method toi thieu:
  - `Future<T> getObject<T>(String path, T Function(Map<String, dynamic>) mapper, {bool authenticated = true})`
  - `Future<List<T>> getList<T>(String path, T Function(Map<String, dynamic>) mapper, {bool authenticated = true})`
  - `Future<T> postObject<T>(String path, Map<String, dynamic> body, T Function(Map<String, dynamic>) mapper)`
  - `Future<T> putObject<T>(String path, Map<String, dynamic>? body, T Function(Map<String, dynamic>) mapper)`
  - `Future<void> delete(String path)`
  - `Future<T> multipartObject<T>(String method, String path, Map<String, String> fields, Map<String, String> filePaths, T Function(Map<String, dynamic>) mapper)`

## Error Handling
- Tao exception dung chung, vi du `ApiException`.
- Exception can co:
  - `message`
  - `statusCode`
  - `code` optional
- Neu token rong:
  - Throw message: `Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.`
- Neu response khong parse duoc JSON:
  - Throw message: `Phản hồi từ máy chủ không hợp lệ.`
- Neu `ApiResponse.success == false`:
  - Uu tien `message` cua BE.
  - Neu BE tra validation map trong `data`, lay loi dau tien de hien thi.
- Neu HTTP `401` hoac `403`:
  - Giu message BE neu co.
  - ViewModel owner phai expose error de UI hien retry/login guidance, khong fallback sample.

## Response Shape
- BE tra wrapper `ApiResponse<T>`.
- Moi service owner phai decode qua `ApiResponse<T>` hien co tai `lib/src/models/api_response.dart`.
- Cac API pagination nhu `/notifications` co `data.content`, `data.totalElements`, `data.totalPages`, `data.number`, `data.size`.

## ViewModel State Standard
- Moi owner ViewModel co state toi thieu:
  - `bool isLoading`
  - `String? errorMessage`
  - data nullable hoac list rong
- Submit action co state rieng neu can:
  - `bool isSubmitting`
  - `String? submitError`
- Refresh action phai goi lai API that.
- Khong set sample data trong `catch` cua owner ViewModel.

## UI State Standard
- Loading lan dau: `CircularProgressIndicator`.
- Empty: text ro rang theo context, vi du `Chưa có ngựa nào trong danh sách.`
- Error: message + nut `Thử lại`.
- Submit loi: hien toast/snackbar voi message BE.
- Submit thanh cong: toast/snackbar + reload data lien quan.

## Acceptance Criteria
- Owner service nao can auth deu gui `Authorization`.
- Loi API owner khong con bi che boi `.sample()`.
- Tests co the inject `MockClient`, `baseUrl`, `AuthStorage`.
- Cac service cu van chay voi `ApiConfig.baseUrl` neu khong inject gi.
