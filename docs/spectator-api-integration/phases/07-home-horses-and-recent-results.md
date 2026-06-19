# Phase 07 - Home Horses And Recent Results

## Muc tieu
- Home featured horses va recent results lay tu API hoac empty state that.

## Endpoints
- Horse/ranking neu BE co:
  - `GET /horses/rankings`
  - `GET /horses`
- Results:
  - `GET /races/{id}/results`
  - race list public neu BE co.

## Mapping
- Featured horses lay top rank/win rate/performance neu BE tra.
- Recent results lay races da co result, hien top 3 gan nhat.
- Neu BE chua co public horse endpoint, hien empty horses state.

## Acceptance Criteria
- Khong dung `SpectatorHomeMock.featuredHorses`.
- Khong dung `SpectatorHomeMock.recentResults`.
- Khong goi `/owner/horses`.
