# Owner API Integration Master Plan

## 1. Muc tieu tong the

Tai lieu nay gom cac plan trien khai owner API integration tu Phase 01 den Phase 08 vao mot file duy nhat. Muc tieu la chia tung phase thanh cac plan nho co ma ro rang de de code, review va verify theo tung buoc.

Nguyen tac chung:

- Chi ap dung cho owner portal trong MO va cac service/model owner dung chung.
- Khong sua BE trong cac phase owner API integration nay.
- Khong lam thay doi flow cua `JOCKEY`, `REFEREE`, `SPECTATOR`, `ADMIN`.
- Giu `ApiConfig.baseUrl` hien tai; khong them `dart-define`, `.env`, hay dependency moi cho config.
- Moi API can dang nhap phai lay token tu `AuthStorage` va gui `Authorization: Bearer <token>`.
- Runtime owner khong fallback sang `.sample()` khi API loi; UI phai hien loading, empty, error va retry that.

## 2. Phase 01 - Owner API Foundation

Muc tieu: chuan hoa nen tang goi API cho owner portal, gom API client, error handling, response wrapper va state chuan cho ViewModel/UI.

### P01.1 - Tao API client dung chung

- Tao helper dung chung, khuyen nghi `lib/src/services/api_client.dart`.
- Constructor nhan `http.Client? client`, `String? baseUrl`, `AuthStorage? storage`.
- Gia tri mac dinh dung `http.Client()`, `ApiConfig.baseUrl`, `AuthStorage()`.
- Ho tro toi thieu cac method:
  - `getObject`
  - `getList`
  - `postObject`
  - `putObject`
  - `delete`
  - `multipartObject`
- API authenticated phai tu dong gan bearer token.

### P01.2 - Chuan hoa error handling

- Tao exception dung chung, vi du `ApiException`.
- Exception co `message`, `statusCode`, `code` optional.
- Token rong: bao loi phien dang nhap het han.
- Response khong parse duoc JSON: bao loi phan hoi may chu khong hop le.
- `ApiResponse.success == false`: uu tien message BE, neu `data` la validation map thi lay loi dau tien.
- HTTP `401` hoac `403`: giu message BE neu co va expose ra ViewModel.

### P01.3 - Chuan hoa response wrapper

- Moi service owner decode qua `ApiResponse<T>` hien co tai `lib/src/models/api_response.dart`.
- API pagination nhu `/notifications` doc `data.content`, `data.totalElements`, `data.totalPages`, `data.number`, `data.size`.
- Service phai cho phep inject `MockClient`, `baseUrl`, `AuthStorage` de test.

### P01.4 - Chuan hoa ViewModel va UI state

- Moi owner ViewModel co `bool isLoading`, `String? errorMessage`, data nullable hoac list rong.
- Submit action co `bool isSubmitting`, `String? submitError` khi can.
- Refresh action phai goi API that.
- UI loading lan dau dung `CircularProgressIndicator`.
- Empty state hien text theo context.
- Error state hien message va nut `Thu lai`.
- Submit loi hien toast/snackbar voi message BE; submit thanh cong reload data lien quan.

### Acceptance Criteria

- Owner service nao can auth deu gui `Authorization`.
- Loi API owner khong bi che boi `.sample()`.
- Test co the inject `MockClient`, `baseUrl`, `AuthStorage`.
- Cac service cu van chay voi `ApiConfig.baseUrl` neu khong inject gi.

## 3. Phase 02 - Owner Current UI API

Muc tieu: noi API that cho 4 tab owner hien co: Dashboard, Tournaments, Horses, Profile; giu layout/navigation hien co va loai bo fallback sample.

### P02.1 - Dashboard API

- Screen: `OwnerDashboardScreen`.
- ViewModel: `OwnerDashboardViewModel`.
- Repository/service lien quan: `OwnerDashboardRepository`, `OwnerDashboardService`, `OwnerHorseService`, `AuthRepository`.
- Endpoints:
  - `GET /owner/dashboard`
  - `GET /tournaments`
  - `GET /owner/horses`
  - `GET /auth/me`
- Mapping:
  - Hero tournament uu tien status `OPEN_REGISTRATION`, `PUBLISHED`, `ONGOING`; neu khong co thi dung tournament gan nhat.
  - Featured horses lay toi da 6 horse tu `/owner/horses`.
  - Upcoming races lay tu `DashboardResponse.upcoming`.
  - Profile image lay tu `/auth/me.avatarUrl`.
- Khong return `OwnerDashboardData.sample()` khi API loi; expose `errorMessage` va retry.

### P02.2 - Tournaments API

- Screens: `OwnerTournamentsScreen`, `OwnerTournamentDetailScreen`.
- Endpoints:
  - `GET /tournaments`
  - `GET /tournaments/{id}`
- Filters:
  - `all`: tat ca.
  - `upcoming`: khong phai `ONGOING`, `COMPLETED`, `CANCELLED`.
  - `ongoing`: `ONGOING`.
  - `completed`: `COMPLETED` hoac `CANCELLED`.
- Khong dung `TournamentListItem.sampleData()` trong owner flow.
- Loi list hien message `Khong the tai giai dau.` va nut retry.

### P02.3 - Horses API hien co

- Screen: `OwnerHorsesScreen`.
- Endpoint: `GET /owner/horses`.
- Map `HorseResponse` sang `OwnerHorseItem` voi cac field horse, image/document, status, review reason, performance, race history.
- BE tra rong thi hien danh sach rong that.
- Search/filter chi chay tren data API.
- Nut add horse co the tam giu TODO cho Phase 03.

### P02.4 - Profile API

- Screen: `OwnerProfileScreen`.
- Endpoints:
  - `GET /auth/me`
  - `GET /users/me/profile` neu can chi tiet profile.
  - `PUT /users/me/profile` cho update sau.
  - `PUT /auth/password` cho doi mat khau.
- Khong dung `RefereeProfileData` lam model runtime lau dai cho owner.
- Neu `/auth/me` loi: hien error va retry, khong tao fake `OWN-000`.
- Logout tiep tuc clear local storage va quay ve login.

### Acceptance Criteria

- Login owner vao 4 tab khong thay data sample cu neu BE rong.
- Tat ca loi API trong 4 tab hien error state.
- Pull-to-refresh goi API that.
- Khong co thay doi hanh vi cac role khac.

## 4. Phase 03 - Owner Horse CRUD

Muc tieu: them full UI va API de owner quan ly ngua, thay nut add horse placeholder bang form that.

### P03.1 - Service/model horse detail va form

- Endpoints:
  - `GET /owner/horses`
  - `GET /owner/horses/{id}`
  - `POST /owner/horses` multipart
  - `PUT /owner/horses/{id}` multipart
  - `DELETE /owner/horses/{id}`
- Hoan thien model owner horse detail voi identity, owner info, thong tin co ban, image/document, status, performance, race history, created/updated time.
- Tao `OwnerHorseFormData` gom field va file path.
- Status label:
  - `PENDING`: `Cho duyet`
  - `APPROVED`: `Da duyet`
  - `REJECTED`: `Tu choi`
  - `SUSPENDED`: `Tam khoa`

### P03.2 - Form create/edit horse

- Screen: `OwnerHorseFormScreen`.
- Fields: ten ngua, giong, tuoi, gioi tinh, mau long, chieu cao cm, can nang kg, anh ngua, tai lieu.
- Create multipart: `name` required max 120; cac field con lai optional theo rule BE; `image`, `document` optional file.
- Update multipart: cung fields voi create, nhung `name` optional.
- Validate client toi thieu theo rule BE.
- Dung dependency hien co `image_picker`, `file_picker` neu da co trong project.

### P03.3 - Detail/list mutation flow

- Screen: `OwnerHorseDetailScreen` hien anh, ten, status, thong tin co ban, performance, race history.
- `OwnerHorsesScreen`: tap card vao detail, add card/FAB vao create form.
- Actions detail: edit, delete neu BE cho phep.
- Sau create/update/delete thanh cong: reload list.

### Edge Cases

- Validation error tu BE: map vao field neu duoc, neu khong hien toast.
- File qua lon/upload loi: hien message BE.
- Delete thanh cong: pop ve list va reload.
- Delete loi vi horse da co activity: hien message BE, khong xoa local item.

### Acceptance Criteria

- Owner tao duoc horse pending tu mobile.
- Owner xem duoc detail horse cua minh.
- Owner cap nhat horse cua minh.
- Owner xoa horse neu BE cho phep.
- List sau moi mutation phan anh data BE.

## 5. Phase 04 - Owner Jockey Invitations

Muc tieu: them UI/API de owner moi jockey cho horse/race, xem invitation va xem jockey da accept de dung cho race registration.

### P04.1 - Service/model invitation

- Endpoints:
  - `GET /users/jockeys`
  - `POST /owner/jockey-invitations`
  - `GET /owner/jockey-invitations`
  - `GET /owner/jockey-invitations/{id}`
  - `GET /owners/me/jockeys`
  - `PUT /owner/jockey-invitations/{id}/cancel`
- Models:
  - `OwnerJockeyInvitation`
  - `OwnerJockeyInvitationFormData`
  - `OwnerAcceptedJockey`
- Repository methods: fetch list/detail, create, cancel, fetch accepted jockeys, fetch available jockeys.

### P04.2 - Create invitation flow

- Screen: `OwnerCreateJockeyInvitationScreen`.
- Body JSON gom `horseId`, `raceId`, `jockeyId`, `remunerationAmount`, `message`.
- Chon horse tu `/owner/horses`, chi nen hien horse `APPROVED`.
- Chon race tu tournament detail context hoac race picker.
- Chon jockey tu `/users/jockeys`.
- Validate remuneration amount >= 0 va message max 1000.

### P04.3 - Invitation list/detail/accepted jockeys

- `OwnerJockeyInvitationsScreen`: list invitation cua owner, filter all/pending/accepted/rejected/cancelled.
- `OwnerJockeyInvitationDetailScreen`: hien horse, race, tournament, jockey, amount, message, response note; pending thi cho cancel.
- `OwnerAcceptedJockeysScreen`: list `/owners/me/jockeys`.
- Navigation:
  - Race card: action `Moi jockey` khi race co the dang ky.
  - Horse detail: action `Moi jockey` khi horse `APPROVED`.
  - Profile/dashboard quick action vao invitation list.

### Edge Cases

- Wallet khong du tien hold remuneration: hien message BE.
- Horse chua approved: client disable, BE loi thi hien message.
- Duplicate invitation hoac jockey/race khong hop le: hien message BE.
- Cancel chi thuc hien khi BE cho phep.

### Acceptance Criteria

- Owner tao duoc invitation.
- Owner xem duoc list/detail invitation.
- Owner huy duoc pending invitation.
- Owner xem duoc accepted jockeys.
- Flow khong dung API jockey decision cua role `JOCKEY`.

## 6. Phase 05 - Owner Race Registration

Muc tieu: cho owner dang ky horse team vao race tu mobile, xem va rut registration cua minh.

### P05.1 - Eligible teams va registration service

- Endpoints:
  - `GET /owner/horse-teams/eligible`
  - `POST /races/{id}/registrations`
  - `GET /owner/race-registrations`
  - `PUT /owner/race-registrations/{id}/withdraw`
- Eligible team response gom invitation, horse, owner, jockey, jockey profile va accepted time.
- Registration request gom `horseId`, `jockeyInvitationId`, `note`.
- Withdraw request co `note` optional.
- Registration response gom race/tournament/owner/horse/jockey/status/fee/note/review fields.

### P05.2 - Register race flow

- Screen: `OwnerRaceRegistrationScreen`.
- Mo tu race card trong tournament detail.
- Hien race name, tournament name, entry fee, participant count neu co.
- Goi `/owner/horse-teams/eligible`.
- Cho owner chon team horse + jockey accepted.
- Submit `POST /races/{id}/registrations`.
- Sau thanh cong: pop ve tournament detail hoac registration detail, hien toast thanh cong.

### P05.3 - Registration list/detail/withdraw

- `OwnerRaceRegistrationsScreen`: list registration cua owner, filter all/pending/approved/rejected/withdrawn.
- `OwnerRaceRegistrationDetailScreen`: hien detail registration.
- Status `PENDING`: hien action withdraw va dialog nhap note optional.
- Tournament detail race section:
  - Hien action `Dang ky` khi tournament/race dang mo dang ky theo BE.
  - Neu chua co eligible team: mo invitation flow hoac hien huong dan tao horse/moi jockey.

### Edge Cases

- Khong co eligible team: empty state `Ban can ngua da duyet va jockey da nhan loi moi.` voi CTA quan ly ngua va moi jockey.
- Entry fee khong du tien: hien message BE va CTA sang wallet.
- Duplicate registration: hien message BE.
- Race het han dang ky: hien message BE va refresh tournament detail.

### Acceptance Criteria

- Owner dang ky duoc race bang eligible horse team.
- Owner xem duoc registrations cua minh.
- Owner rut duoc pending registration.
- UI khong dung registration API admin.

## 7. Phase 06 - Owner Races, Results, Prizes, Complaints

Muc tieu: hoan thien owner flow sau khi da dang ky race: xem lich dua, ket qua, giai thuong va gui complaint.

### P06.1 - Owner races va race detail

- Endpoint: `GET /owner/races`.
- Dung `RaceResponse` tu BE.
- `OwnerRacesScreen`: filter upcoming, ongoing, completed/cancelled.
- `OwnerRaceDetailScreen`: hien race info, participants/results tab neu co, action xem ket qua khi da co result, action complaint khi BE cho phep.
- Race data toi thieu: id/name, tournament id/name neu co, status, scheduled start/end, venue/location, participant info neu co.

### P06.2 - Results va prizes

- Endpoints:
  - `GET /races/{id}/results`
  - `GET /owner/prizes`
- `OwnerRaceResultsScreen`: hien bang xep hang/result tu `RaceResultResponse`.
- Result hien rank, horse, owner, jockey, finish/result fields neu co, `ownerPrizeAmount`, `jockeyPrizeAmount`.
- `OwnerPrizesScreen`: hien prize transactions tu `WalletTransactionResponse`.
- Prize hien amount, direction, type, status, reference, note, createdAt.

### P06.3 - Complaints

- Endpoints:
  - `POST /races/{id}/complaints`
  - `GET /owner/race-complaints`
- `OwnerComplaintsScreen`: list complaint va status.
- `OwnerCreateComplaintScreen`: mo tu race result/detail, chon accused participant, nhap reason va evidence URL optional.
- Complaint request gom `accusedParticipantId`, `reason` 1..2000, `evidenceUrl` optional max 1000.

### Navigation

- Dashboard quick action vao `OwnerRacesScreen`.
- Profile/dashboard quick action vao `OwnerPrizesScreen`, `OwnerComplaintsScreen`.
- Race detail -> results -> complaint.

### Edge Cases

- Race chua co result: results screen hien empty `Chua co ket qua.`
- Khong co participant de complaint: disable submit.
- Complaint qua han hoac khong hop le: hien message BE.
- Prize list rong: empty state.

### Acceptance Criteria

- Owner xem duoc lich/my races.
- Owner xem duoc ket qua race.
- Owner xem duoc prize transactions.
- Owner tao duoc complaint hop le va xem lai complaint list.

## 8. Phase 07 - Owner Wallet And Notifications

Muc tieu: them UI/API vi va thong bao cho owner portal, dung wallet API chung theo token owner.

### P07.1 - Wallet overview va transactions

- Endpoints:
  - `GET /wallets/me`
  - `GET /wallets/me/transactions`
- `OwnerWalletScreen`: hien available, hold, total, currency, wallet status.
- Tabs: transactions, deposit orders, withdrawals.
- Wallet response gom id, ownerType, userId, currency, balances, status, created/updated time.
- Transaction response gom balance before/after, type, direction, amount, status, reference, metadata, note, createdAt.

### P07.2 - Deposit orders

- Endpoints:
  - `POST /wallets/me/deposit-orders`
  - `GET /wallets/me/deposit-orders`
  - `GET /wallets/me/deposit-orders/{id}`
- `OwnerDepositScreen`: nhap amount, chon provider neu UI co enum; neu khong de null.
- Deposit request gom amount > 0, currency default `VND`, provider optional.
- Sau create, hien checkout URL, QR, transfer content neu response co; neu khong hien order status.

### P07.3 - Withdrawals

- Endpoints:
  - `POST /wallets/me/withdrawals`
  - `GET /wallets/me/withdrawals`
  - `GET /wallets/me/withdrawals/{id}`
- `OwnerWithdrawalScreen`: nhap amount, bank name, account number, account name, reason.
- Validate cac field required va amount > 0.
- Withdrawal response gom amount/currency/status/bank info/reason/admin note/approved/rejected/paid/created time.

### P07.4 - Notifications

- Endpoints:
  - `GET /notifications?status=&page=0&size=20`
  - `GET /notifications/unread-count`
  - `PUT /notifications/{id}/read`
  - `PUT /notifications/read-all`
- `OwnerNotificationsScreen`: list paginated notifications.
- Filter unread/read/all neu can.
- Tap item mark single read.
- Action mark all read.
- Navigation: profile settings them `Vi cua toi`, `Thong bao`; dashboard quick links co the them neu phu hop design.

### Edge Cases

- Wallet chua ton tai: hien message BE neu BE khong auto create.
- Deposit provider null: chap nhan neu BE chap nhan.
- Checkout URL rong: hien transfer content/QR neu co, neu khong hien order status.
- Withdrawal amount lon hon available: hien message BE.
- Notifications page rong: empty state.

### Acceptance Criteria

- Owner xem duoc vi va transaction.
- Owner tao duoc deposit order.
- Owner tao duoc withdrawal request.
- Owner xem notifications, unread count, mark read, mark all read.

## 9. Phase 08 - Owner Test Checklist

Muc tieu: dam bao owner API integration khong fallback sample va khong anh huong role khac.

### P08.1 - Unit tests cho services

- Dung `MockClient` cho moi service owner.
- Moi endpoint can co case:
  - Success 2xx, `success: true`.
  - BE business error, `success: false`.
  - 401/403.
  - Validation error map trong `data`.
  - Non-JSON response.
  - Empty list.
- Assert URL dung `baseUrl`.
- Assert header `Accept: application/json`.
- Assert header `Authorization` co bearer token voi API authenticated.
- Assert body JSON/multipart dung field BE yeu cau.

### P08.2 - Unit tests cho models

- Parse day du va optional-missing cho horse response.
- Parse `DashboardResponse` voi `wallet`, `upcoming`, `recentTransactions`, `recentNotifications`.
- Parse jockey invitation, eligible horse team, race registration, race complaint.
- Parse wallet, wallet transaction.
- Parse notification page response co `content`.

### P08.3 - ViewModel tests

- Dashboard: loading -> success; API loi -> `errorMessage`, `data == null`, khong sample.
- Horses: API rong -> list rong; API loi -> error va list rong; search/filter tren data API.
- Tournaments: filters dung status; detail loi -> error state.
- Horse CRUD: submit success reload list; validation loi expose message.
- Invitations: create success reload list/detail; cancel success update status.
- Registration: no eligible teams -> empty state; register success; withdraw success update status.
- Wallet/Notifications: deposit/withdraw success; mark read update unread count.

### P08.4 - Widget tests

- Moi owner screen chinh test initial loading, empty state, error state + retry, success render data.
- Form screens test required validation, submit disabled khi invalid/busy, submit success feedback, submit error message.

### P08.5 - Manual test Android emulator

- Chay BE local port 8080.
- Chay MO voi `flutter pub get` va `flutter run`.
- Dang nhap tai khoan role `OWNER`.
- Verify dashboard, tournament list/detail, horse CRUD, jockey invitations, race registration, owner races/results, complaint, wallet, deposit, withdrawal, notifications.

### P08.6 - Regression checklist

- Login/navigation role owner van vao `OwnerShell`.
- Role khac van vao shell cu cua ho.
- `ApiConfig.baseUrl` van giu logic hien tai:
  - Web: `localhost`
  - Android emulator: `10.0.2.2`
  - iOS/desktop: `localhost`
- Khong sua BE.
- Khong commit/generated churn ngoai scope owner neu khong can.

### Done Criteria

- Tat ca service tests owner pass.
- Tat ca model parsing tests pass.
- Owner ViewModel tests khang dinh khong fallback sample khi API loi.
- Manual flow owner chay duoc tren emulator voi BE local.
