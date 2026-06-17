# Phase 13 - Jockey Wallet

## Muc tieu
- Them wallet flow trong jockey portal.
- Dung route chung theo token jockey.

## Endpoints
- `GET /wallets/me`
- `GET /wallets/me/transactions`
- `POST /wallets/me/deposit-orders`
- `GET /wallets/me/deposit-orders`
- `GET /wallets/me/deposit-orders/{id}`
- `POST /wallets/me/withdrawals`
- `GET /wallets/me/withdrawals`
- `GET /wallets/me/withdrawals/{id}`

## UI
- `JockeyWalletScreen`:
  - available, hold, total, currency, status
  - tabs transactions/deposit orders/withdrawals
- `JockeyDepositScreen`:
  - amount, provider optional
  - hien checkoutUrl/qrCode/transferContent neu co
- `JockeyWithdrawalScreen`:
  - amount, bankName, bankAccountNumber, bankAccountName, reason

## Acceptance Criteria
- Jockey xem wallet/transactions.
- Tao deposit order duoc.
- Tao withdrawal request duoc.
- Loi tien khong du hien message BE.
