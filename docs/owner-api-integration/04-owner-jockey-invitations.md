# Phase 04 - Owner Jockey Invitations

## Muc tieu
- Them UI/API de owner moi jockey cho horse/race va xem danh sach invitation.
- Ho tro xem jockey da accept de dung cho race registration.

## Endpoints
- `GET /users/jockeys` authenticated
- `POST /owner/jockey-invitations` authenticated
- `GET /owner/jockey-invitations` authenticated
- `GET /owner/jockey-invitations/{id}` authenticated
- `GET /owners/me/jockeys` authenticated
- `PUT /owner/jockey-invitations/{id}/cancel` authenticated

## Create Invitation Request
- JSON body:
  - `horseId` required
  - `raceId` required
  - `jockeyId` required
  - `remunerationAmount` required, >= 0
  - `message` optional, max 1000

## Response Fields
- `id`
- `ownerId`
- `ownerUsername`
- `jockeyId`
- `jockeyUsername`
- `jockeyProfileId`
- `horseId`
- `horseName`
- `raceId`
- `raceName`
- `tournamentId`
- `tournamentName`
- `status`
- `message`
- `responseNote`
- `remunerationAmount`
- `respondedAt`
- `cancelledAt`
- `createdAt`
- `updatedAt`

## UI Screens
- `OwnerJockeyInvitationsScreen`
  - List invitation cua owner.
  - Filter status: all, pending, accepted, rejected, cancelled.
  - Tap item -> detail.
- `OwnerJockeyInvitationDetailScreen`
  - Hien horse, race, tournament, jockey, amount, message, response note.
  - Neu status pending: hien action cancel.
- `OwnerCreateJockeyInvitationScreen`
  - Chon horse tu `/owner/horses` chi nen hien horse `APPROVED`.
  - Chon race tu tournament detail context hoac race picker.
  - Chon jockey tu `/users/jockeys`.
  - Nhap remuneration amount.
  - Nhap message optional.
- `OwnerAcceptedJockeysScreen`
  - List `/owners/me/jockeys`.
  - Dung lam reference de owner biet horse nao da co jockey accepted.

## Navigation
- Tu tournament race card: action `Mời jockey` neu race lien quan dang co the dang ky.
- Tu horse detail: action `Mời jockey` neu horse `APPROVED`.
- Tu profile/dashboard quick action: vao invitation list.

## Service/Repository
- Tao `OwnerJockeyInvitationService`.
- Tao models:
  - `OwnerJockeyInvitation`
  - `OwnerJockeyInvitationFormData`
  - `OwnerAcceptedJockey`
- Repository methods:
  - `fetchInvitations()`
  - `fetchInvitationDetail(id)`
  - `createInvitation(data)`
  - `cancelInvitation(id)`
  - `fetchAcceptedJockeys()`
  - `fetchAvailableJockeys()`

## Edge Cases
- Wallet khong du tien hold remuneration: hien message BE.
- Horse chua approved: client nen disable, BE loi thi hien message.
- Invitation duplicate hoac jockey/race khong hop le: hien message BE.
- Cancel chi thuc hien khi BE cho phep.

## Acceptance Criteria
- Owner tao duoc invitation.
- Owner xem duoc list/detail invitation.
- Owner huy duoc pending invitation.
- Owner xem duoc accepted jockeys.
- Flow khong dung API jockey decision cua role `JOCKEY`.
