# Changelog

## [Unreleased]
### Added
- **Samaj Ratna Management**: Added complete CRUD operations for Samaj Ratna in Admin Panel.
- **Samaj Ratna Backend**: Implemented `SamajRatna` Prisma model and NestJS REST API endpoints (`/api/v1/admin/samaj-ratna`).
- **Samaj Ratna Flutter**: Built `SamajRatnaScreen` utilizing `flutter_riverpod` connecting directly to backend API.
- **Architectural Rules**: Documented strictly controlled routing mechanism in `architecture.md`.

### Changed
- **Home Screen Admin Panel**: Refactored `admin/home-screen` route editing to be read-only with fixed application-controlled routes mapping. Added direct "Manage Content" redirection links.
- **Backend Settings API**: Refactored `SettingsService` to ignore payload `route` attributes and strictly enforce server-side predefined routing for Home Buttons.
- **Flutter Home Router**: Verified `/birthdays` is fully implemented and hooked up to `todaysBirthdaysProvider`.
