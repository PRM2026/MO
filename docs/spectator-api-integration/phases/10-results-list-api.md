# Phase 10 - Results List API

## Muc tieu
- Thay `SpectatorResultsMock` bang result data that.

## Endpoints
- `GET /races/{id}/results`
- Race list public hoac tournament detail de tim race da co result.

## UI
- `SpectatorResultsScreen` hien list result groups.
- Top 3 finishers hien tren card.
- Neu BE khong co category cu, doi filter sang:
  - all
  - recent
  - verified

## Acceptance Criteria
- Khong import `spectator_results_mock.dart`.
- Results empty khi BE chua co ket qua.
- Error + retry khi API loi.
