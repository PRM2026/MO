# Phase 05 - Jockey Profile Read

## Muc tieu
- Doc full profile cua jockey tu BE.
- Thay `RefereeProfileData.sample` bang model jockey profile rieng.

## Endpoint
- `GET /jockey/profile`

## Response Fields
- `id`, `userId`, `username`, `fullName`
- `licenseNumber`, `experienceYears`
- `heightCm`, `weightKg`
- `bio`, `awards`, `achievements`, `specialties`
- `avatarUrl`, `licenseDocumentUrl`
- `status`, `reviewReason`, `reviewedBy`, `reviewedAt`
- `performance`, `raceHistory`
- `createdAt`, `updatedAt`

## UI
- `JockeyProfileScreen` hien:
  - avatar, full name, username
  - license/status/review reason
  - stats/performance
  - bio/awards/specialties
  - race history

## Acceptance Criteria
- Profile load tu `/jockey/profile`.
- Status rejected/suspended hien `reviewReason`.
- Loi profile hien retry, khong fake profile.
