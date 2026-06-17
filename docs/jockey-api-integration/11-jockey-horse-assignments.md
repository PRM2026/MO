# Phase 11 - Jockey Horse Assignments

## Muc tieu
- Hoan thien man Horses cua jockey ma khong bịa endpoint `/jockey/horses`.
- Hien ngua/assignment tu data BE hien co.

## Data Sources
- `GET /jockey/invitations`
- `GET /jockey/races`
- `GET /jockey/profile`

## Mapping
- Accepted invitation -> assigned horse item.
- Race response -> schedule/race context.
- Profile raceHistory -> history context.
- Item hien:
  - horseName
  - ownerUsername
  - raceName
  - tournamentName
  - status
  - remunerationAmount
  - scheduledStartAt neu resolve duoc

## UI
- Doi title/empty text theo nghia assignment, vi du `Ngua duoc phan cong`.
- Tap item mo invitation detail hoac race detail tuy data co id nao.

## Acceptance Criteria
- Khong goi owner API.
- No accepted invitation -> empty state.
- Data khong fallback sample.
