# Phase 07 - Owner Wallet And Notifications

## Muc tieu
- Them UI/API vi va thong bao cho owner portal.
- Dung wallet API chung theo token owner, khong tao route owner rieng.

## Wallet Endpoints
- `GET /wallets/me`
- `GET /wallets/me/transactions`
- `POST /wallets/me/deposit-orders`
- `GET /wallets/me/deposit-orders`
- `GET /wallets/me/deposit-orders/{id}`
- `POST /wallets/me/withdrawals`
- `GET /wallets/me/withdrawals`
- `GET /wallets/me/withdrawals/{id}`

## Wallet Response
- `id`
- `ownerType`
- `userId`
- `currency`
- `availableBalance`
- `holdBalance`
- `totalBalance`
- `status`
- `createdAt`
- `updatedAt`

## Transaction Response
- `id`
- `walletId`
- `userId`
- `type`
- `direction`
- `amount`
- `availableBefore`
- `availableAfter`
- `holdBefore`
- `holdAfter`
- `status`
- `referenceType`
- `referenceId`
- `metadata`
- `note`
- `createdAt`

## Deposit Order
- Request:
  - `amount` required, > 0
  - `currency` default `VND`
  - `provider` optional
- Response:
  - `id`
  - `amount`
  - `currency`
  - `provider`
  - `status`
  - `referenceCode`
  - `checkoutUrl`
  - `qrCode`
  - `transferContent`
  - `paidAt`
  - `expiredAt`
  - `createdAt`

## Withdrawal
- Request:
  - `amount` required, > 0
  - `bankName` required
  - `bankAccountNumber` required
  - `bankAccountName` required
  - `reason` optional
- Response:
  - `id`
  - `amount`
  - `currency`
  - `status`
  - `bankName`
  - `bankAccountNumber`
  - `bankAccountName`
  - `reason`
  - `adminNote`
  - `approvedAt`
  - `rejectedAt`
  - `paidAt`
  - `createdAt`

## Notification Endpoints
- `GET /notifications?status=&page=0&size=20`
- `GET /notifications/unread-count`
- `PUT /notifications/{id}/read`
- `PUT /notifications/read-all`

## Notification Response
- `id`
- `recipientId`
- `recipientUsername`
- `type`
- `title`
- `message`
- `referenceType`
- `referenceId`
- `metadataJson`
- `readAt`
- `createdAt`

## UI Screens
- `OwnerWalletScreen`
  - Hien available, hold, total, currency, wallet status.
  - Tabs: transactions, deposit orders, withdrawals.
  - CTA: deposit, withdraw.
- `OwnerDepositScreen`
  - Nhap amount.
  - Chon provider neu UI co enum provider; neu khong de null.
  - Sau create, hien checkout URL/QR/transfer content neu response co.
- `OwnerWithdrawalScreen`
  - Nhap amount, bank name, account number, account name, reason.
  - Validate field required.
- `OwnerNotificationsScreen`
  - List paginated notifications.
  - Filter unread/read/all neu can.
  - Mark single read khi tap item.
  - Action mark all read.

## Navigation
- Owner profile settings them item:
  - `Ví của tôi`
  - `Thông báo`
- Owner dashboard quick links co the them wallet/notifications neu design phu hop.

## Edge Cases
- Wallet chua ton tai: BE service co the auto create hoac tra loi; UI hien message BE neu loi.
- Deposit provider null: chap nhan neu BE chap nhan.
- Checkout URL rong: hien transfer content/QR neu co; neu khong hien order status.
- Withdrawal amount lon hon available: hien message BE.
- Notifications page rong: empty state.

## Acceptance Criteria
- Owner xem duoc vi va transaction.
- Owner tao duoc deposit order.
- Owner tao duoc withdrawal request.
- Owner xem notifications, unread count, mark read, mark all read.
