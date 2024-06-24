# Changelog

All notable changes to `Backy` will be documented in this file.

## [Unreleased]
### Added
- Support for turning off replication
- Added support for config by environment in .backyrc

### Changed
- Breaking change; Change in config keys
- Internal refactoring

## [0.1.8] - 2024-06-22
### Fixed
- Ensure that the dependencies are installed

## [0.1.7] - 2024-06-21
### Added
- Support for setting database params via PG_URL
- Make S3 bucket prefix configurable

## [0.1.6] - 2023-12-28
### Added
- Support for parallel pg_dump processes.
- Support for parallel pg_restore processes.
- Added CLI

### Changed
- Improved performance of the backup process.
- Rename gem from `backy` to `backy_rb`.

## [0.1.3] - 2023-06-23
- Initial release of `Backy`.
- Support for AWS S3 integration.
- Rails application auto-configuration feature.
