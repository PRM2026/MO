# Phase 06 - Jockey Profile Update

## Muc tieu
- Them form cap nhat profile jockey.
- Gui multipart dung contract BE.

## Endpoint
- `PUT /jockey/profile`

## Multipart Fields
- `licenseNumber` optional, max 100
- `experienceYears` optional, integer >= 0
- `heightCm` optional number
- `weightKg` optional number
- `bio` optional, max 1000
- `awards` optional, max 2000
- `specialties` optional, max 1000
- `avatar` optional file
- `achievements` optional file/image
- `licenseDocument` optional file

## UI
- Tao `JockeyProfileEditScreen`.
- Dung `image_picker`/`file_picker` dependency hien co.
- Submit success reload profile.
- Submit error hien message BE.

## Acceptance Criteria
- Jockey update duoc text profile.
- Jockey upload duoc avatar/license document/achievements neu chon file.
- Validation client toi thieu theo rule BE.
