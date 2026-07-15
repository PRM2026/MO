# Spectator API Integration - Small Phases Roadmap

## Muc tieu

File nay tach bo spec spectator API integration thanh cac phase nho hon de de code, review va test. Scope chi la role `SPECTATOR`; khong sua flow `OWNER`, `JOCKEY`, `REFEREE`, `ADMIN`.

## Nguyen tac chung

- Public spectator API goi voi `authenticated: false`.
- Profile/account API goi authenticated bang token tu `AuthStorage`.
- Khong goi endpoint owner-only nhu `/owner/dashboard`, `/owner/horses`, `/owner/races`, `/owner/prizes`.
- Khong fallback mock/sample trong runtime spectator.
- Production spectator screen khong import `lib/src/data/spectator_*_mock.dart`.
- Neu BE chua co endpoint public cho race/horse/ranking, UI hien empty/error state that va ghi TODO endpoint ro, khong hard-code data.

## Thu tu code khuyen nghi

1. `phases/01-foundation-service-contract.md`
2. `phases/02-shared-models-and-mappers.md`
3. `phases/03-viewmodel-state-standard.md`
4. `phases/04-home-profile-summary.md`
5. `phases/05-home-featured-tournament.md`
6. `phases/06-home-upcoming-races.md`
7. `phases/07-home-horses-and-recent-results.md`
8. `phases/08-races-list-api.md`
9. `phases/09-race-detail-screen.md`
10. `phases/10-results-list-api.md`
11. `phases/11-race-leaderboard-detail.md`
12. `phases/12-tournament-detail-public.md`
13. `phases/13-horse-ranking-public.md`
14. `phases/14-profile-account-api.md`
15. `phases/15-ui-polish-and-navigation.md`
16. `phases/16-tests-and-regression.md`

## Phase Summary

| Phase | Muc tieu | Files lien quan chinh |
| --- | --- | --- |
| 01 | Tao service/repository contract cho spectator | services, repositories |
| 02 | Tao model/mapper spectator | models |
| 03 | Chuan hoa ViewModel state | viewmodels |
| 04 | App bar profile summary that | home/profile auth |
| 05 | Home featured tournament | home |
| 06 | Home upcoming races | home/races |
| 07 | Home horses va recent results | home/results |
| 08 | Races list/filter API | races |
| 09 | Race detail screen | races/routes |
| 10 | Results list API | results |
| 11 | Leaderboard detail | results/routes |
| 12 | Public tournament detail | tournaments |
| 13 | Public horse/ranking | horses/home |
| 14 | Profile/account API | profile |
| 15 | UI polish/navigation/remove placeholder | widgets/routes |
| 16 | Tests va regression | test |

## Done Criteria

- Tat ca phase nho co file spec rieng.
- Co the implement tung phase doc lap, review tung PR nho.
- Sau phase 16, spectator portal khong con runtime mock/hard-code va co test coverage cho service/model/viewmodel/widget chinh.
