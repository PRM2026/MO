String walletStatusLabel(String? status) {
  return switch (status) {
    'ACTIVE' => 'Hoạt động',
    'LOCKED' => 'Tạm khóa',
    'CLOSED' => 'Đã đóng',
    _ => status ?? '—',
  };
}

String walletTransactionTypeLabel(String? type) {
  return switch (type) {
    'DEPOSIT' => 'Nạp tiền',
    'WITHDRAW' => 'Rút tiền',
    'ADMIN_WITHDRAW' => 'Rút quỹ',
    'ENTRY_FEE' => 'Phí đăng ký',
    'LATE_CHECK_IN_FEE' => 'Phí check-in muộn',
    'JOCKEY_HIRE' => 'Thuê jockey',
    'JOCKEY_PAYOUT' => 'Thanh toán jockey',
    'JOCKEY_HIRE_TAX' => 'Thuế thuê jockey',
    'BET_STAKE' => 'Tiền cược',
    'BET_PAYOUT' => 'Thưởng cược',
    'PRIZE_PAYOUT' => 'Tiền thưởng',
    'ITEM_PURCHASE' => 'Mua vật phẩm',
    'ITEM_SALE' => 'Bán vật phẩm',
    'REFUND' => 'Hoàn tiền',
    'ADJUSTMENT' => 'Điều chỉnh',
    _ => type ?? 'Giao dịch',
  };
}

String walletTransactionDirectionLabel(String? direction) {
  return switch (direction) {
    'CREDIT' => 'Cộng tiền',
    'DEBIT' => 'Trừ tiền',
    'HOLD' => 'Tạm giữ',
    'RELEASE' => 'Hoàn giữ',
    'CAPTURE' => 'Tất toán giữ',
    _ => direction ?? '—',
  };
}

String walletTransactionStatusLabel(String? status) {
  return switch (status) {
    'PENDING' => 'Đang chờ',
    'SUCCESS' => 'Thành công',
    'FAILED' => 'Thất bại',
    'REVERSED' => 'Đã đảo',
    _ => status ?? '—',
  };
}

bool isWalletCreditDirection(String? direction) {
  return direction == 'CREDIT' || direction == 'RELEASE';
}
