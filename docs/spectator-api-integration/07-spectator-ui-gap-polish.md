# Phase 07 - Spectator UI Gap Polish

## Muc tieu
- Hoan thien cac UI state con thieu sau khi keo API.
- Xoa placeholder runtime va dieu huong that cho spectator.
- Dam bao mobile layout khong bi vo khi data BE dai/ngan bat thuong.

## Gaps hien tai can xu ly
- `SpectatorHomeScreen`:
  - Bo mock featured event/upcoming horses/results.
  - Hero detail action mo tournament/race detail that.
- `SpectatorRacesScreen`:
  - Bo mock schedule hero/list.
  - Bo toast `Dang mo ...`; tap card mo detail.
  - Date filter dung data API.
- `SpectatorResultsScreen`:
  - Bo mock results.
  - Bo toast leaderboard/VIP placeholder.
  - Promo VIP chi giu neu co flow that; neu chua co thi an.
- `SpectatorProfileScreen`:
  - Bo mock avatar fallback URL.
  - Them error + retry.

## UI Components
- Them component state dung chung cho spectator neu can:
  - loading panel
  - empty panel
  - error panel with retry
- Giu style hien co: `SpectatorGlassCard`, `SpectatorAppBar`, `SpectatorBottomNav`.
- Text dai tu BE phai wrap, khong overflow.
- Anh rong/sai: fallback icon/gradient noi bo, khong hard-code URL ngoai.

## Navigation
- Them routes spectator rieng:
  - race detail
  - race results/leaderboard
  - tournament detail neu implement
  - horse/ranking list neu BE co
- Khong tai su dung routes owner/jockey cho spectator detail.
- Bottom nav giu 4 tab hien co: Home, Races, Results, Profile.

## Removal Checklist
- Production spectator files khong import:
  - `spectator_home_mock.dart`
  - `spectator_races_mock.dart`
  - `spectator_results_mock.dart`
- Khong con toast placeholder cho action chinh.
- Khong con date hard-code ket thuc nam 2026 trong date picker.

## Acceptance Criteria
- Tat ca man spectator co loading, empty, error, retry.
- Dieu huong tu card/action chinh mo man that hoac an/disable neu chua co flow.
- UI render on dinh voi list rong, text dai, image rong.
- Role khac khong doi behavior.
