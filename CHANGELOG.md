# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0-beta.9] - 2026-06-19

### Added

- Added a canonical component registry for shared runtime, docs, and public API metadata.
- Added field-family components for grouped fields, fieldsets, legends, content, titles, and separators.
- Added typography recipes with opt-in alias helpers.
- Added composed docs recipes, including auth form, settings page, admin shell, data table, date input, field-family, and typography examples.
- Added modular Cinder UI hook source templates and a build script for generated JavaScript assets.
- Added Netlify preview/site deployment support and static hosting documentation.

### Changed

- Decomposed forms and advanced components into focused modules while preserving the public component surface.
- Reworked static docs generation around shared renderers, metadata extraction, inline examples, recipes, sample assets, and theme-model data.
- Improved docs theme behavior and added a homepage command palette.
- Improved installer JavaScript hook patching and generated asset checks.
- Updated visual regression snapshots for the new docs, recipes, and component examples.
- Removed the retired `earmark` dependency.

### Fixed

- Fixed stale generated JavaScript handling by serving generated Cinder UI JavaScript in the demo app.
- Fixed generated demo CSS checks in CI.
- Fixed cleared autocomplete selection updates.
- Fixed `Forms.input` example stripping in docs.
- Fixed input group button spacing and restored focused input group button/text helpers.
- Fixed registry alias ordering.

## [0.1.0-beta.6] - 2026-05-07

### Added

- Added interactive docs links to component and component-family HexDocs.
- Added docs catalog support for stripping generated self-links from static docs pages.

### Changed

- Improved docs theme persistence and refresh behavior across the homepage and docs site.
- Improved form field label rendering and examples.
- Updated static docs screenshots after intentional visual changes.

### Fixed

- Fixed native select sizing and shared form control class handling.
- Fixed select focus management and related keyboard interaction coverage.
- Fixed flash dismiss icon alignment.

## [0.1.0-beta.1] - 2026-03-16

### Added

- First public beta release for Hex publishing and release-process validation.
- Initial release.
