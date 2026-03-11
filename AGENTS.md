# Repository Guide

`cinder_ui` is a Phoenix + LiveView component library with a demo app and static docs export.

## Key Paths

- `lib/cinder_ui/`: library components, icons, hooks, classes
- `priv/templates/`: source of truth for `cinder_ui.js` and `cinder_ui.css`
- `dev/`: static docs/site code
- `demo/`: local integration app and browser tests

## Working Rules

- Edit `priv/templates/cinder_ui.js` and `priv/templates/cinder_ui.css`; do not edit `demo/assets/js/cinder_ui.js` or `demo/assets/css/cinder_ui.css` because they are generated copies.
- Keep APIs Phoenix-first: HEEx function components, predictable assigns, typed `attr` and `slot`.
- Prefer composing with existing components in docs and examples; use raw HTML only when necessary.
- Keep demo and static docs behavior aligned, including snippets, theme controls, and interactions.
- Update tests when component behavior, docs generation, or JS hooks change.
- Update `README.md`, `CONTRIBUTING.md`, and in-module docs/examples when public behavior changes.
- Use repository-relative paths in docs.
- RTL support is out of scope unless a maintainer explicitly asks for it.

## Commands

Run from the repository root unless noted.

- `mix quality`
- `MIX_ENV=test mix coveralls.cobertura --raise`
- `mix cinder_ui.docs.build`
- `cd demo && mix format --check-formatted && mix test`
- `cd demo && npm ci && mix assets.build && npx playwright test`

## Release

1. Bump the version in `mix.exs` and update `CHANGELOG.md`.
2. Run the required quality, coverage, docs, and demo checks.
3. Publish to Hex manually.
4. Publish the GitHub release to trigger Pages deploy.
