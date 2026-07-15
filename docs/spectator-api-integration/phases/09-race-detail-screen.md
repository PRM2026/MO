# Phase 09 - Race Detail Screen

## Muc tieu
- Them man detail cho race spectator.
- Bo toast placeholder khi tap race card.

## Endpoints
- `GET /races/{id}` public neu BE co.
- Fallback dung race data da lay tu tournament detail.
- `GET /races/{id}/results` de biet co ket qua hay chua.

## UI
- Hien race name, tournament, venue, distance, time, status.
- Hien participants count va prizes neu public.
- Action `Xem ket qua` enable khi co result.
- Neu chua co result, hien `Chua co ket qua.`

## Navigation
- Them route spectator race detail rieng trong `AppRoutes`.
- Tap race card mo detail.

## Acceptance Criteria
- Khong dung route owner/jockey/referee.
- Detail co loading/error/retry.
- Race card khong con toast `Dang mo ...`.
