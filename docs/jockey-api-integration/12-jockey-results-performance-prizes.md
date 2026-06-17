# Phase 12 - Jockey Results Performance Prizes

## Muc tieu
- Hoan thien man Results voi performance, results va prize payout.

## Endpoints
- `GET /jockey/performance`
- `GET /jockey/races`
- `GET /races/{id}/results`
- `GET /jockey/prizes`

## UI
- `JockeyResultsScreen`:
  - KPI performance
  - recent races/results
  - prize payout summary
- `JockeyPrizesScreen` neu can:
  - amount
  - type/direction/status
  - reference
  - note
  - createdAt

## Mapping
- Performance KPI tu `JockeyPerformanceResponse`.
- Results tu `RaceResultResponse`.
- Prizes tu `WalletTransactionResponse`.

## Acceptance Criteria
- Results/performance/prizes load tu API.
- Race chua finalized hien pending/no result.
- Payout rong hien empty state.
