# Phase 08 - Jockey Invitations Actions

## Muc tieu
- Them accept/reject invitation.
- Sau action reload list/detail.

## Endpoints
- `PUT /jockey/invitations/{id}/accept`
- `PUT /jockey/invitations/{id}/reject`

## Request Body
- Optional:
  - `note` max 1000
- Neu note rong, gui `{}`.

## UI
- Detail invitation status `PENDING` hien:
  - Accept
  - Reject
- Moi action mo dialog nhap note optional.
- Dang submit thi disable buttons.

## Business Notes
- Khi jockey accept mot invitation, BE co the cancel pending invitation khac.
- Sau action phai reload list de status cap nhat.

## Acceptance Criteria
- Accept/reject dung endpoint jockey.
- Loi action hien message BE.
- Non-pending invitation khong hien action.
