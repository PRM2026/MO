# Phase 03 - Owner Horse CRUD

## Muc tieu
- Them full UI va API de owner quan ly ngua.
- Thay nut add horse placeholder bang form that.

## Endpoints
- `GET /owner/horses`
- `GET /owner/horses/{id}`
- `POST /owner/horses` multipart, authenticated
- `PUT /owner/horses/{id}` multipart, authenticated
- `DELETE /owner/horses/{id}` authenticated

## Request Fields
- Multipart fields cho create:
  - `name` required, max 120
  - `breed` optional, max 120
  - `age` optional, integer >= 0
  - `gender` optional, max 40
  - `color` optional, max 80
  - `heightCm` optional number
  - `weightKg` optional number
  - `image` optional file
  - `document` optional file
- Multipart fields cho update:
  - Cung fields voi create, nhung `name` optional.

## Response Model
- Tao/hoan thien model owner horse detail gom:
  - `id`
  - `ownerId`
  - `ownerUsername`
  - `name`
  - `breed`
  - `age`
  - `gender`
  - `color`
  - `heightCm`
  - `weightKg`
  - `imageUrl`
  - `documentUrl`
  - `status`
  - `reviewReason`
  - `performance`
  - `raceHistory`
  - `createdAt`
  - `updatedAt`
- Status label:
  - `PENDING`: `Chờ duyệt`
  - `APPROVED`: `Đã duyệt`
  - `REJECTED`: `Từ chối`
  - `SUSPENDED`: `Tạm khóa`

## UI Screens
- `OwnerHorseDetailScreen`
  - Hien anh, ten, status, thong tin co ban, performance, race history.
  - Actions:
    - Edit
    - Delete chi enable neu status cho phep BE xoa; neu BE tu choi thi hien message BE.
- `OwnerHorseFormScreen`
  - Dung cho create va edit.
  - Fields:
    - Ten ngua
    - Giong
    - Tuoi
    - Gioi tinh
    - Mau long
    - Chieu cao cm
    - Can nang kg
    - Anh ngua
    - Tai lieu
  - Validate client toi thieu theo rule BE.
- `OwnerHorsesScreen`
  - Tap card -> detail.
  - Add card/FAB -> create form.
  - Sau create/update/delete thanh cong -> reload list.

## Service/Repository
- Mo rong `OwnerHorseService`:
  - `getOwnerHorses()`
  - `getOwnerHorse(String id)`
  - `createHorse(OwnerHorseFormData data)`
  - `updateHorse(String id, OwnerHorseFormData data)`
  - `deleteHorse(String id)`
- Tao `OwnerHorseFormData` de gom field va file path.
- File picker:
  - Co the dung dependency hien co `image_picker`, `file_picker`.
  - Anh dung `image`.
  - Tai lieu dung `document`.

## Edge Cases
- BE tra validation error: hien loi gan form neu map duoc field, neu khong hien toast.
- File qua lon hoac upload loi: hien message BE.
- Delete thanh cong: pop ve list va reload.
- Delete loi vi horse da co activity: hien message BE, khong xoa local item.

## Acceptance Criteria
- Owner tao duoc horse pending tu mobile.
- Owner xem detail horse cua minh.
- Owner cap nhat horse cua minh.
- Owner xoa horse neu BE cho phep.
- List sau moi mutation phan anh data BE.
