# Phase 06 - Owner Races, Results, Prizes, Complaints

## Muc tieu
- Hoan thien owner flow sau khi da dang ky race: xem lich dua, ket qua, giai thuong, va gui complaint.

## Endpoints
- `GET /owner/races` authenticated
- `GET /owner/prizes` authenticated
- `GET /races/{id}/results` public/auth optional
- `POST /races/{id}/complaints` authenticated
- `GET /owner/race-complaints` authenticated

## Race Data
- Dung `RaceResponse` tu BE.
- Owner UI can hien toi thieu:
  - race id/name
  - tournament id/name neu response co
  - status
  - scheduled start/end
  - venue/location
  - participant info neu co

## Results Data
- Dung `RaceResultResponse`.
- Hien:
  - rank
  - horse name
  - owner username
  - jockey username
  - finish time/result fields neu co
  - `ownerPrizeAmount`
  - `jockeyPrizeAmount`

## Prizes Data
- Endpoint `/owner/prizes` tra `WalletTransactionResponse`.
- Hien:
  - amount
  - direction
  - type
  - status
  - reference type/id
  - note
  - createdAt

## Complaint Request
- JSON body:
  - `accusedParticipantId` required
  - `reason` required, 1..2000
  - `evidenceUrl` optional, max 1000

## Complaint Response
- `id`
- `raceId`
- `raceName`
- `complainantOwnerId`
- `accusedOwnerId`
- `accusedOwnerUsername`
- `accusedParticipantId`
- `accusedHorseId`
- `accusedHorseName`
- `status`
- `reason`
- `evidenceUrl`
- `adminNote`
- `ownerPrizeReturnAmount`
- `fineAmount`
- `totalPenaltyAmount`
- `banUntil`
- `createdAt`
- `resolvedAt`
- `resolvedBy`

## UI Screens
- `OwnerRacesScreen`
  - List `/owner/races`.
  - Filter: upcoming, ongoing, completed/cancelled.
  - Tap race -> detail.
- `OwnerRaceDetailScreen`
  - Hien race info.
  - Tab participants/results neu data co.
  - Action xem ket qua neu race da co result.
  - Action complaint neu race da co result va BE cho phep.
- `OwnerRaceResultsScreen`
  - Goi `/races/{id}/results`.
  - Hien bang xep hang/result.
- `OwnerPrizesScreen`
  - Goi `/owner/prizes`.
  - Hien transaction prize.
- `OwnerComplaintsScreen`
  - Goi `/owner/race-complaints`.
  - Hien list complaint va status.
- `OwnerCreateComplaintScreen`
  - Mo tu race result/detail.
  - Chon accused participant tu result/participant list neu co.
  - Nhap reason.
  - Nhap evidence URL optional.

## Navigation
- Dashboard quick action -> `OwnerRacesScreen`.
- Profile/dashboard quick action -> `OwnerPrizesScreen`, `OwnerComplaintsScreen`.
- Race detail -> results -> complaint.

## Edge Cases
- Race chua co result: results screen hien empty `Chưa có kết quả.`
- Khong co participant de complaint: disable submit.
- Complaint qua han hoac khong hop le: hien message BE.
- Prize list rong: empty state.

## Acceptance Criteria
- Owner xem duoc lich/my races.
- Owner xem duoc ket qua race.
- Owner xem duoc prize transactions.
- Owner tao duoc complaint hop le va xem lai complaint list.
