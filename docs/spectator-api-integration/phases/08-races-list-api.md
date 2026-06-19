# Phase 08 - Races List API

## Muc tieu
- Thay `SpectatorRacesMock` bang list race API.

## Endpoints
- `GET /races` public neu BE co.
- Fallback `GET /tournaments` va `GET /tournaments/{id}`.

## UI
- `SpectatorRacesScreen` filter tren data API:
  - upcoming
  - finished
  - date
- Date picker khong hard-code nam 2026.
- Schedule hero lay tu featured/upcoming race that hoac an neu khong co data.

## Acceptance Criteria
- `SpectatorRacesScreen` khong import `spectator_races_mock.dart`.
- Filter date dung `scheduledStartAt`.
- Empty/error/retry hien dung.
