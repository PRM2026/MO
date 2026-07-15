# Phase 12 - Public Tournament Detail

## Muc tieu
- Hoan thien public tournament detail cho spectator.

## Endpoints
- `GET /tournaments`
- `GET /tournaments/{id}`

## UI
- Detail hien:
  - name, description, location
  - banner/status
  - registration/start/end time
  - rules
  - races list
  - prizes neu co trong races
- Race item trong detail mo Race Detail.

## Code Note
- Co the adapter tu `OwnerTournamentDetail` ban dau.
- Code moi nen co naming spectator rieng de tranh phu thuoc owner.

## Acceptance Criteria
- Hero Home co the mo tournament detail.
- Detail khong fallback sample.
- Khong goi endpoint `/owner/...`.
