# Phase 02 - Shared Models And Mappers

## Muc tieu
- Tao model spectator de UI khong phu thuoc lau dai vao mock hoac owner naming.

## Can code
- Tao model:
  - `SpectatorHomeData`
  - `SpectatorRaceItem`
  - `SpectatorRaceDetail`
  - `SpectatorResultGroup`
  - `SpectatorResultFinisher`
  - `SpectatorProfileData`
- Tao mapper tu response BE sang UI model.
- Co the adapter tu `TournamentListItem` va `OwnerTournamentDetail` trong phase dau, nhung code spectator moi nen co naming spectator.

## Mapping default
- Date parse ve local time.
- Status normalize uppercase.
- Image URL resolve qua helper hien co neu co.
- Field missing hien `--` hoac empty state, khong tao fake value.

## Acceptance Criteria
- Model parse duoc response day du va optional missing.
- Khong co hard-code sample trong factory/model.
- Model khong import widget.
