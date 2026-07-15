# Phase 03 - ViewModel State Standard

## Muc tieu
- Chuan hoa loading/error/empty/retry cho moi man spectator.

## Can code
- Tao ViewModel rieng:
  - `SpectatorHomeViewModel`
  - `SpectatorRacesViewModel`
  - `SpectatorRaceDetailViewModel`
  - `SpectatorResultsViewModel`
  - `SpectatorRaceResultsViewModel`
  - `SpectatorProfileViewModel`
- Moi ViewModel co:
  - `bool isLoading`
  - `String? errorMessage`
  - data nullable hoac list rong
  - `Future<void> load()`
  - `Future<void> retry()`
- Submit/action state them rieng khi can.

## Acceptance Criteria
- Loi service khong bi swallow.
- Retry goi lai API.
- Empty list tu BE giu rong that.
- Khong set mock data trong catch.
