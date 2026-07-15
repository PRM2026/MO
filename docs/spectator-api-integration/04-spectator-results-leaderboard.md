# Phase 04 - Spectator Results And Leaderboard

## Muc tieu
- Thay `SpectatorResultsMock` bang API that.
- Hien danh sach ket qua va bang xep hang theo race.
- Bo toast placeholder cho leaderboard/VIP.

## Endpoints
- `GET /races/{id}/results` public.
- Public race list/detail neu BE co:
  - `GET /races`
  - `GET /races/{id}`
- Fallback lay race tu tournament detail:
  - `GET /tournaments`
  - `GET /tournaments/{id}`

## Model
- `SpectatorResultGroup` gom:
  - `raceId`, `raceName`, `tournamentId`, `tournamentName`
  - `distance`, `venue`, `scheduledStartAt`
  - `status`, `verified`
  - `finishers`
- `SpectatorResultFinisher` gom:
  - `rank`, `horseId`, `horseName`
  - `jockeyId`, `jockeyName`
  - `ownerId`, `ownerUsername` neu BE public cho phep
  - `finishTime`, `resultStatus`, `note`
  - prize amount neu BE public cho phep

## UI
- `SpectatorResultsScreen`:
  - Load list races da co result.
  - Filter hien co can map thanh API data:
    - `all`: tat ca ket qua.
    - Cac category cu chi giu neu BE co category/tournament series.
    - Neu BE khong co category, doi filter thanh all/recent/verified trong phase polish.
  - Card hien top 3 finishers va metadata race.
- `SpectatorRaceResultsScreen` moi hoac detail mode:
  - Hien full leaderboard cua mot race.
  - Hien rank, horse, jockey, finish time/status.
  - Empty state `Chua co ket qua cho cuoc dua nay.`

## Data Flow
- Results tab lay danh sach race completed/result-confirmed.
- Goi `/races/{id}/results` cho tung race can hien.
- Race nao result rong thi bo qua list tong hop, nhung detail van hien empty state.
- Neu BE co endpoint list results tong hop sau nay, repository co the thay implementation nhung giu ViewModel contract.

## Edge Cases
- Result API public yeu cau login: service phai expose loi 401/403, UI hien message dang nhap neu can.
- Mot race co result partial: hien field co data, field missing hien `--`.
- Ket qua chua verified: badge `Cho xac nhan` neu BE co status.

## Acceptance Criteria
- Results tab khong import `spectator_results_mock.dart`.
- Leaderboard action mo man that, khong hien toast placeholder.
- Recent/results data den tu API hoac empty state that.
- Khong goi endpoint role khac.
