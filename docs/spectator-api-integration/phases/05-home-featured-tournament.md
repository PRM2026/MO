# Phase 05 - Home Featured Tournament

## Muc tieu
- Hero Home lay featured event tu public tournament API.

## Endpoints
- `GET /tournaments`
- `GET /tournaments/{id}` neu can detail.

## Mapping
- Uu tien status:
  - `OPEN_REGISTRATION`
  - `PUBLISHED`
  - `ONGOING`
- Neu khong co, chon tournament co `startAt` gan nhat trong tuong lai.
- Neu BE rong, Home hien empty hero state.
- Image lay tu `bannerUrl`; neu rong dung fallback noi bo.

## Acceptance Criteria
- Hero khong dung `SpectatorHomeMock.featuredEvent`.
- Tap hero mo tournament detail neu route da co, hoac race/tournament flow that theo phase 12.
- Khong fallback sample tournament.
