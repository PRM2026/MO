# Phase 04 - Jockey Dashboard Performance

## Muc tieu
- Tach KPI/performance ra phase rieng de dashboard nhe hon.
- Dung `/jockey/performance` lam source thanh tich.

## Endpoint
- `GET /jockey/performance`

## Response Fields
- `jockeyId`
- `raceCount`
- `completedRaceCount`
- `firstPlaces`
- `secondPlaces`
- `thirdPlaces`
- `totalJockeyPayout`
- `totalPrizePayout`
- `recentRaces`

## UI Mapping
- KPI cards:
  - Tong cuoc dua
  - Da hoan thanh
  - Hang 1/2/3
  - Thu lao/payout
  - Prize payout
- Recent races co the hien tren dashboard hoac results.

## Acceptance Criteria
- Dashboard KPI dung performance API.
- Neu performance rong/null, hien zero state that.
- Recent races khong dung sample.
