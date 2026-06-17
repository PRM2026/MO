# Phase 14 - Jockey Notifications

## Muc tieu
- Them notification center cho jockey portal.

## Endpoints
- `GET /notifications?status=&page=0&size=20`
- `GET /notifications/unread-count`
- `PUT /notifications/{id}/read`
- `PUT /notifications/read-all`

## UI
- `JockeyNotificationsScreen`:
  - paginated list
  - unread count
  - filter all/unread/read neu can
  - tap item mark read
  - action mark all read

## Data Fields
- `id`
- `type`
- `title`
- `message`
- `referenceType`
- `referenceId`
- `metadataJson`
- `readAt`
- `createdAt`

## Acceptance Criteria
- Notifications load page API.
- Mark read/all read update unread count.
- Empty page hien empty state.
