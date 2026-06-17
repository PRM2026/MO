# Phase 03 - Jockey Dashboard API

## Muc tieu
- Keo overview dashboard tu BE.
- Giu layout dashboard hien co, thay data sample bang API.

## Endpoints
- `GET /jockey/dashboard`
- `GET /auth/me`
- `GET /jockey/invitations`

## Mapping
- Profile name/avatar tu `/auth/me` hoac `DashboardResponse.account`.
- Alerts tu `DashboardResponse.alerts`.
- Upcoming tu `DashboardResponse.upcoming`.
- Quick links tu `DashboardResponse.quickLinks`.
- Pending invitation count tinh tu `/jockey/invitations`.

## UI
- `JockeyDashboardScreen` hien:
  - greeting/profile
  - cards tong quan
  - upcoming races
  - invitation pending
  - quick links

## Acceptance Criteria
- Dashboard load API that.
- Loi dashboard hien retry.
- Khong return `JockeyDashboardData.sample()` trong repository/viewmodel runtime.
