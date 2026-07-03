# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.2] - 2026-07-03

### Changed

- Cinder UI now inlines the `tailwindcss-animate` animation utilities directly into its CSS (via the Tailwind v4 `tw-animate-css` port). Consuming apps no longer need the `tailwindcss-animate` npm package — the animation classes resolve straight from `deps/cinder_ui` with no peer dependency or extra setup. This also fixes plugin resolution failures under the default (non-copy) install, where `@plugin "tailwindcss-animate"` could not be resolved from `deps/cinder_ui`.

### Removed

- Removed copy mode from `mix cinder_ui.install` (the `--copy`, `--skip-existing`, and `--package-manager` options) along with the npm install step. With the animation utilities inlined, the installer only patches `app.css` and `app.js` to reference `deps/cinder_ui`; `--assets-path`, `--skip-patching`, and `--dry-run` remain.

## [0.2.0] - 2026-07-03

### Changed

- `mix cinder_ui.install` now references Cinder UI's CSS and JS directly from `deps/cinder_ui` by default instead of copying them into your project, so they stay in sync automatically on upgrade. It patches `app.css` to `@import` the library CSS from deps and `app.js` to import `CinderUIHooks` from the `cinder_ui` package (resolved via Phoenix's esbuild `NODE_PATH`).

### Added

- Added a `--copy` flag to `mix cinder_ui.install` that restores the previous behavior of vendoring `cinder_ui.css`/`cinder_ui.js` into `assets/`. Use it to customize the shipped files or when your build cannot resolve `deps/cinder_ui`. Re-run with `--copy --skip-patching` to refresh copies after upgrading.
- Added a root `package.json` (shipped in the Hex package) exposing `priv/templates/cinder_ui/index.js` so consumers can `import { CinderUIHooks } from "cinder_ui"`.

## [0.1.1] - 2026-07-03

### Added

- Added autocomplete and combobox visual regression coverage, including custom and grouped item examples.

### Changed

- Improved autocomplete and combobox slot rendering for richer item content.

### Fixed

- Fixed select click-open behavior so the current selection is not highlighted as an active navigation target.

## [0.1.0] - 2026-06-19

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
