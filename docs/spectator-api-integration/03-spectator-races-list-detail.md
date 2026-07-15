# Phase 03 - Spectator Races List And Detail

## Muc tieu
- Thay `SpectatorRacesMock` bang API that.
- Hoan thien Races tab voi list, filter va man race detail.
- Bo toast placeholder `Dang mo ...`.

## Endpoints
- Public race list/detail neu BE co:
  - `GET /races`
  - `GET /races/{id}`
- Fallback contract neu BE chua co race list public:
  - `GET /tournaments`
  - `GET /tournaments/{id}` de lay `races`.
- Results trong detail:
  - `GET /races/{id}/results` public.

## Model
- `SpectatorRaceItem` gom:
  - `id`, `tournamentId`, `tournamentName`
  - `name`, `distance`, `venue`
  - `scheduledStartAt`, `scheduledEndAt`
  - `status`, `participantCount`, `maxParticipants`
  - `bannerUrl` hoac image fallback noi bo
- `SpectatorRaceDetail` gom race info, tournament info, participant summary, prizes neu BE tra, result availability.

## UI
- `SpectatorRacesScreen`:
  - Filter `upcoming`: race chua ket thuc va khong cancelled.
  - Filter `finished`: status `COMPLETED`, `RESULT_CONFIRMED`, hoac cancelled neu can hien lich su.
  - Filter `date`: list race co `scheduledStartAt` cung ngay duoc chon.
  - Date picker `lastDate` khong hard-code 2026; dung nam hien tai + 3 hoac max date tu data.
- `SpectatorRaceDetailScreen` moi:
  - Hien title, tournament, venue, distance, time, status, participant count.
  - Hien prizes neu co.
  - Hien action xem ket qua khi race co result.
  - Neu chua co result, action disabled hoac hien empty text.

## Navigation
- Tap race card mo `SpectatorRaceDetailScreen`.
- Tu detail, action results mo result/leaderboard cua race.
- AppRoutes them route spectator detail rieng, khong dung route jockey/owner.

## Edge Cases
- Race list rong: hien `Chua co cuoc dua nao.`
- Date filter khong co item: hien `Khong co cuoc dua trong ngay da chon.`
- Detail API loi: hien error + retry.
- Race bi cancelled: hien status ro, khong hien action result neu khong co result.

## Acceptance Criteria
- Races tab khong import `spectator_races_mock.dart`.
- Filter chay tren data API.
- Race card mo detail that.
- Khong goi endpoint owner/jockey/referee.
