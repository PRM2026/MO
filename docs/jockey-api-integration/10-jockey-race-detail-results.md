# Phase 10 - Jockey Race Detail Results

## Muc tieu
- Tao race detail read-only cho jockey.
- Cho xem ket qua race neu co.

## Endpoints
- `GET /jockey/races`
- `GET /races/{id}/results`
- `GET /tournaments/{id}/jockey-challenge`

## UI
- `JockeyRaceDetailScreen`:
  - race name, distance, venue, schedule, status
  - referee
  - participant count
  - prizes
  - note
- `JockeyRaceResultsScreen`:
  - rank
  - horse/owner/jockey
  - finish time
  - challenge points
  - jockey prize
  - payout status

## Rules
- Chi read-only.
- Khong dung endpoint referee/admin.
- Challenge standings chi hien neu co tournamentId.

## Acceptance Criteria
- Race detail load tu API.
- Results empty hien `Chua co ket qua.`
- Current jockey row duoc highlight neu match jockeyId.
