# Phase 07 - Jockey Invitations List Detail

## Muc tieu
- Chuan hoa list/detail loi moi cua jockey.
- Phase nay chi doc data, chua accept/reject.

## Endpoints
- `GET /jockey/invitations`
- `GET /jockey/invitations/{id}`

## Response Fields
- `id`, `ownerId`, `ownerUsername`
- `jockeyId`, `jockeyUsername`, `jockeyProfileId`
- `horseId`, `horseName`
- `raceId`, `raceName`
- `tournamentId`, `tournamentName`
- `status`, `message`, `responseNote`
- `remunerationAmount`
- `respondedAt`, `cancelledAt`, `createdAt`, `updatedAt`

## UI
- List filter: all, pending, accepted, rejected, cancelled.
- Detail hien owner, horse, race, tournament, amount, message, status.
- Empty state khi khong co invitation.

## Acceptance Criteria
- List/detail load API that.
- `JockeyInvitationService` dung `ApiClient`.
- Khong fallback sample.
