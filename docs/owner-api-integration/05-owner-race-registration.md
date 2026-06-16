# Phase 05 - Owner Race Registration

## Muc tieu
- Cho owner dang ky horse team vao race tu mobile.
- Cho owner xem va rut registration cua minh.

## Endpoints
- `GET /owner/horse-teams/eligible` authenticated
- `POST /races/{id}/registrations` authenticated
- `GET /owner/race-registrations` authenticated
- `PUT /owner/race-registrations/{id}/withdraw` authenticated

## Eligible Horse Team Response
- `invitationId`
- `horseId`
- `horseName`
- `ownerId`
- `ownerUsername`
- `jockeyId`
- `jockeyUsername`
- `jockeyProfileId`
- `jockeyFullName`
- `acceptedAt`

## Registration Request
- JSON body:
  - `horseId` required
  - `jockeyInvitationId` required
  - `note` optional, max 1000

## Withdraw Request
- JSON body optional:
  - `note` optional, max 1000

## Registration Response
- `id`
- `raceId`
- `raceName`
- `tournamentId`
- `ownerId`
- `ownerUsername`
- `horseId`
- `horseName`
- `jockeyId`
- `jockeyUsername`
- `jockeyInvitationId`
- `status`
- `entryFeeAmount`
- `ownerNote`
- `reviewNote`
- `withdrawNote`
- `reviewedBy`
- `reviewedAt`
- `createdAt`
- `updatedAt`

## UI Screens
- `OwnerRaceRegistrationScreen`
  - Mo tu race card trong tournament detail.
  - Hien race name, tournament name, entry fee, participant count neu co.
  - Goi `/owner/horse-teams/eligible`.
  - Cho owner chon team: horse + jockey accepted.
  - Nhap note optional.
  - Submit `POST /races/{id}/registrations`.
- `OwnerRaceRegistrationsScreen`
  - List registrations cua owner.
  - Filter: all, pending, approved, rejected, withdrawn.
  - Item hien race, tournament, horse, jockey, fee, status.
- `OwnerRaceRegistrationDetailScreen`
  - Hien detail registration.
  - Neu status `PENDING`: hien action withdraw.
  - Withdraw mo dialog nhap note optional.

## Tournament Detail Integration
- Trong `OwnerTournamentRacesSection`, moi race co action:
  - `Đăng ký` neu tournament/race dang mo dang ky theo status BE.
  - Neu chua co eligible team: action mo invitation flow hoac hien huong dan tao horse/moi jockey.
- Sau registration thanh cong:
  - Pop ve tournament detail hoac registration detail.
  - Hien toast thanh cong.

## Edge Cases
- Khong co eligible team:
  - Hien empty state: `Bạn cần ngựa đã duyệt và jockey đã nhận lời mời.`
  - CTA: `Quản lý ngựa` va `Mời jockey`.
- Entry fee khong du tien:
  - Hien message BE, CTA sang wallet.
- Duplicate registration:
  - Hien message BE.
- Race het han dang ky:
  - Hien message BE va refresh tournament detail.

## Acceptance Criteria
- Owner dang ky duoc race bang eligible horse team.
- Owner xem duoc registrations cua minh.
- Owner rut duoc pending registration.
- UI khong dung registration API admin.
