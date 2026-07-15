# Phase 06 - Home Upcoming Races

## Muc tieu
- Home upcoming races lay tu API.

## Endpoints
- Uu tien `GET /races` public neu BE co.
- Fallback `GET /tournaments/{id}` va doc `races`.

## Mapping
- Upcoming la race chua ket thuc va khong cancelled.
- Sap xep theo `scheduledStartAt` tang dan.
- Hien toi da 3 race tren Home.
- Status open/pending map tu status BE, khong hard-code.

## Acceptance Criteria
- Home khong dung `SpectatorHomeMock.upcomingRaces`.
- Neu khong co race, hien empty state.
- Tap race mo detail that sau phase 09.
