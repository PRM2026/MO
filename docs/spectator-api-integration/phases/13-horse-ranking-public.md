# Phase 13 - Public Horse Ranking

## Muc tieu
- Keo public horse/ranking data cho spectator neu BE co.

## Endpoints
- `GET /horses/rankings`
- `GET /horses`
- `GET /horses/{id}` neu co detail.

## UI
- Home hien featured horses tu ranking.
- Quick action `Chien ma` mo ranking/list neu implement.
- Horse card hien name, rank, image, performance/win rate neu public.

## Fallback khi BE chua co endpoint
- Khong tao mock.
- Hien empty state `Chua co bang xep hang ngua.`
- Ghi TODO endpoint trong service/doc.

## Acceptance Criteria
- Khong goi `/owner/horses`.
- Khong dung `SpectatorHomeMock.featuredHorses`.
- Empty state that khi BE chua co data.
