# Phase 02 - Jockey ViewModel And UI State

## Muc tieu
- Chuan hoa state cho cac ViewModel jockey.
- Loai bo `.sample()` trong runtime catch.

## ViewModel Standard
- Moi ViewModel co:
  - `bool isLoading`
  - `String? errorMessage` hoac `String? loadError`
  - data nullable hoac list rong
- Action ViewModel co:
  - `bool isSubmitting` hoac `bool isProcessing`
  - `String? actionError`
- Refresh phai goi API that.

## UI Standard
- Loading lan dau: spinner.
- Empty: text theo context.
- Error: message + nut `Thu lai`.
- Action error: toast/snackbar message BE.
- Action success: toast/snackbar + reload data lien quan.

## Files Can Sua Sau Khi Implement
- `jockey_dashboard_viewmodel.dart`
- `jockey_schedule_viewmodel.dart`
- `jockey_horses_viewmodel.dart`
- `jockey_results_viewmodel.dart`
- `jockey_profile_viewmodel.dart`
- `jockey_invitation_viewmodel.dart`

## Acceptance Criteria
- API loi khong hien sample data.
- BE tra list rong thi UI hien empty state.
- Role khac khong bi anh huong.
