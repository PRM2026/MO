# Phase 09 - Jockey Schedule List Calendar

## Muc tieu
- Keo lich dua jockey tu `/jockey/races`.
- Build calendar/list mode tu data BE.

## Endpoint
- `GET /jockey/races`

## Race Fields Can Dung
- `id`, `tournamentId`, `name`, `distance`
- `venueName`, `venueAddress`, `provinceName`
- `scheduledStartAt`, `scheduledEndAt`
- `refereeUsername`
- `status`, `participantCount`

## UI Mapping
- Date key tu `scheduledStartAt`.
- Time label tu `scheduledStartAt`.
- Venue label join venue/province.
- Status label theo BE status.
- Race khong co date dua vao nhom `Chua len lich`.

## Acceptance Criteria
- `JockeyScheduleScreen` dung `/jockey/races`.
- Calendar/list filter tren data API.
- Bo hoac doi `confirmRace` thanh local-only neu BE khong co endpoint.
