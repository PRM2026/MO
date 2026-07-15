# Phase 02 - Spectator Home API

## Muc tieu
- Thay `SpectatorHomeMock` bang API that cho Home tab.
- Giu layout hien co cua `SpectatorHomeScreen`.
- Home phai hien loading, empty, error va retry that.

## Endpoints
- `GET /tournaments` public.
- `GET /tournaments/{id}` public khi can lay races cho featured tournament.
- `GET /races/{id}/results` public de lay recent results neu BE chua co endpoint tong hop.
- Public race list/detail neu BE co, vi du:
  - `GET /races`
  - `GET /races/{id}`
- Public horse/ranking endpoint neu BE co, vi du:
  - `GET /horses/rankings`
  - `GET /horses`

## Data Mapping
- Featured event:
  - Uu tien tournament status `OPEN_REGISTRATION`, `PUBLISHED`, `ONGOING`.
  - Neu khong co thi chon tournament co `startAt` gan nhat trong tuong lai.
  - Image lay tu `bannerUrl`; neu rong thi dung placeholder asset/design trung tinh, khong dung URL mock.
- Upcoming races:
  - Lay tu public race list neu co.
  - Neu BE chua co race list public, lay races trong `GET /tournaments/{featuredId}` va cac tournament sap toi.
  - Status open/pending map tu race/tournament status that.
- Featured horses:
  - Lay tu public horse ranking endpoint neu co.
  - Neu BE chua co endpoint, hien empty state `Chua co bang xep hang ngua.`
- Recent results:
  - Lay cac race da co ket qua tu public race list/detail va goi `/races/{id}/results`.
  - Neu chua co ket qua, hien empty state.
- Profile app bar:
  - Lay name/avatar tu `/auth/me` neu user dang login.
  - Neu profile fail, chi hien fallback text generic, khong dung mock image URL.

## Can sua
- `SpectatorHomeScreen` khong import `spectator_home_mock.dart`.
- Tao `SpectatorHomeViewModel` de load home data va profile summary.
- Tao repository method `fetchHomeData()` tong hop tournament/race/result/horse data.
- `SpectatorHeroBanner`, `SpectatorRaceListTile`, `SpectatorFeaturedHorseCard`, `SpectatorRecentResultsPanel` nhan data tu ViewModel.
- Quick actions giu navigation sang tabs races/results.

## Edge Cases
- `/tournaments` rong: featured event empty, upcoming races empty.
- Featured tournament khong co race: upcoming races empty.
- Race result API loi tung race: bo qua race do, nhung neu tat ca loi thi hien error phu hop.
- Anh rong/sai URL: component image dung fallback visual noi bo, khong dung hard-code network mock.

## Acceptance Criteria
- Home khong hien data mock khi BE rong.
- Home reload/retry goi API that.
- Featured event, upcoming races, featured horses, recent results deu tu API hoac empty state that.
- Khong goi endpoint `/owner/...`.
