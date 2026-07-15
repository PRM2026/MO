# Phase 05 - Spectator Tournaments And Horses

## Muc tieu
- Keo full public tournament data cho spectator.
- Bo phu thuoc dai han vao naming owner trong public tournament detail neu can.
- Keo public horse/ranking data neu BE co endpoint.

## Endpoints
- `GET /tournaments` public.
- `GET /tournaments/{id}` public.
- Public horse/ranking neu BE co:
  - `GET /horses`
  - `GET /horses/{id}`
  - `GET /horses/rankings`

## Tournament Spec
- Co the tai su dung `TournamentListItem` trong phase dau vi service public da co.
- Khong dung `TournamentRepository.fetchTournaments()` neu method con fallback `TournamentListItem.sampleData()`.
- Detail co the adapter tu `OwnerTournamentDetail`, nhung nen tao alias/model spectator de tranh owner naming trong code moi:
  - `SpectatorTournamentDetail`
  - `SpectatorTournamentRace`
  - `SpectatorRacePrize`
- Mapping can giu:
  - identity, name, description, location/province
  - banner, status, registration window
  - start/end, rules
  - min/max teams, min/max horses per owner neu public
  - races va prizes neu public

## Horse/Ranking Spec
- Neu BE co public horse ranking:
  - Hien top horses tren Home.
  - Them man/list optional tu quick action `Chien ma noi bat`.
- Horse card gom:
  - horse id/name, image, breed/age/gender neu public
  - owner/jockey display neu public
  - rank/win rate/performance neu public
- Neu BE chua co public horse endpoint:
  - Home hien empty state cho featured horses.
  - Spec ghi TODO endpoint BE ro, khong hard-code data.

## UI Gap
- Neu spectator can xem tournament detail:
  - Tap featured event hoac race tournament label mo detail.
  - Detail hien races list va action xem race detail.
- Quick action `Chien ma` chi enable khi co man/list horse; neu chua implement thi an/disable co copy ro.

## Edge Cases
- Tournament detail khong co races: hien empty races section.
- Horse image rong: dung fallback local/UI, khong network mock.
- Public horse endpoint bi 403: hien message BE, khong fallback sample.

## Acceptance Criteria
- Spectator dung public tournament API that.
- Khong co sample tournament trong spectator runtime.
- Khong goi `/owner/horses`.
- Horse/ranking neu BE chua co thi UI rong that va spec TODO ro.
