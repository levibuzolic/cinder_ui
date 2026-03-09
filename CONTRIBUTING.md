# Contributing to Cinder UI

Thanks for contributing. This guide is for humans first: the goal is to help you get productive quickly, run the right checks, and submit high-signal changes.

## Ground Rules

- Keep APIs Phoenix-first (`attr`/`slot`-typed function components, clear HEEx usage).
- Keep styles aligned with shadcn conventions and token model.
- Prefer composition with Cinder UI components in docs/examples.
- Ship tests with behavior changes.
- Keep `README.md` user-focused and keep contributor workflow docs here.

## Prerequisites

- Elixir (via `mise` is recommended in this repo)
- Node.js + npm (for demo asset and browser tests)
- Chromium for Playwright (`npx playwright install --with-deps chromium`)

## Local Setup

```bash
./bin/bootstrap
```

Notes:

- `./bin/bootstrap` runs `mise trust`, `mise install`, and dependency installation for both the repo root and `demo`.
- `./bin/bootstrap` also installs git hooks via `lefthook install`.
- Root package includes `lucide_icons` as an optional dependency for `CinderUI.Icons.icon/1` and icon-backed component primitives.
- Demo includes `lucide_icons` directly so browser/docs examples always render icon previews.
- Hex package artifacts intentionally ship only runtime modules and `mix cinder_ui.install`; static docs/site build tasks remain repository-only maintainer tooling.

## Git Hooks (Lefthook + mise)

- Hook config lives in `.lefthook.yml`.
- Hooks run through `mise exec` so tool versions come from `.mise.toml`.
- Install/update hooks at any time with:

```bash
mise exec -- lefthook install
```

Default hooks:

- `pre-commit`: root+demo formatting, root compile warnings check, root+demo credo.
- `pre-push`: full root quality/coverage/docs build plus demo unit/assets/browser checks.

## Development Workspaces

- Library: `lib/cinder_ui/**`
- Public install task: `lib/mix/tasks/cinder_ui.install.ex`
- Internal docs/site tasks: `dev/lib/mix/tasks/**`
- Static docs catalog definitions: `dev/lib/cinder_ui/docs/catalog.ex`
- Demo integration app: `demo`
- Browser tests: `demo/tests/browser/**`
- Long-lived competitive roadmap and backlog: `docs/competitive-audit-roadmap.md`

## Typical Workflow

1. Implement the component/task change in library code.
2. Update docs/examples if API or behavior changed.
3. Update static docs catalog sample(s) in `dev/lib/cinder_ui/docs/catalog.ex`.
4. Add or adjust unit/browser tests.
5. If the change relates to strategic component coverage or interaction quality, update `docs/competitive-audit-roadmap.md`.
6. Run quality gates.

## Quality Gates

Run from repo root unless noted.

### Root quality + tests

```bash
mix quality
MIX_ENV=test mix coveralls.cobertura --raise
```

### Static exports

```bash
mix cinder_ui.docs.build
```

From `demo/`, export the live-rendered Phoenix pages to `dist/site` (GitHub Pages artifact):

```bash
cd demo
mix site.export
```

Generate HexDocs with refreshed component screenshots:

```bash
mix docs.with_screenshots
```

Note: docs CSS is compiled with Tailwind CLI from `dev/assets/docs/package.json`. The build task auto-installs those npm dependencies on first run.

### Demo unit tests

```bash
cd demo
mix format --check-formatted
mix test
```

### Browser tests (Playwright)

```bash
cd demo
mix assets.build
npx playwright test
```

Visual suite only:

```bash
cd demo
npx playwright test tests/browser/visual.spec.ts
```

This suite also exports component screenshots to `doc/screenshots` for HexDocs module docs image references.

Promoted example visual suite:

```bash
cd demo
npx playwright test tests/browser/example_visual.spec.ts
```

Update visual baselines (only when UI change is intentional):

```bash
cd demo
npx playwright test tests/browser/visual.spec.ts --update-snapshots
npx playwright test tests/browser/example_visual.spec.ts --update-snapshots
```

## Documentation Expectations

- `README.md`: only user-facing install/usage/docs guidance.
- `CONTRIBUTING.md`: maintainer and contributor workflow.
- Module/function docs: use markdown, include realistic examples, and include multiple named fenced HEEx examples where useful.
- Visual regression policy:
  - Tier 1: every public component gets one baseline snapshot from the docs overview card.
  - Tier 2: only examples marked with the inline-docs `vrt` fence flag get dedicated snapshots from the component detail page.
  - Promote examples only when they add a distinct visual or behavioral state such as open/expanded overlays, invalid/loading/disabled form states, grouped or filtered options, alternative layout orientation, or materially different composition.
  - Do not promote examples that only change copy, labels, or other low-signal cosmetic variations.
  - Use the fence metadata marker for promoted example snapshots, for example: ```` ```heex title="Validation state" align="full" vrt ````. The `vrt` marker is consumed by the docs builder and is not shown in rendered docs.

Example inline docs pattern:

~~~elixir
@doc """
```heex title="Primary"
<.button>Save</.button>
```

```heex title="Secondary"
<.button variant={:outline}>Cancel</.button>
```
"""
~~~

## Pull Request Checklist

- [ ] Change is scoped and documented.
- [ ] Unit tests updated/passing.
- [ ] Browser tests updated/passing (if UI/interaction changed).
- [ ] Static docs/site build successfully.
- [ ] Snapshots updated only for intentional visual changes.

## Commit Style

Use concise, scoped commit messages. Existing style examples:

- `docs(samples): expand rich component examples`
- `test(visual): stabilize snapshots for cross-env size jitter`
- `docs(progress): log milestone update`

## Release Process

1. Update version and changelog (`mix.exs`, `CHANGELOG.md`).
2. Run all quality gates above.
3. Confirm release secrets/environments are configured (one-time setup below).
4. Site deploys automatically on every `main` push via `.github/workflows/publish-site.yml`.
5. Publish GitHub release (triggers `.github/workflows/publish-hex.yml` and also runs `.github/workflows/publish-site.yml`).
5. If needed, run `.github/workflows/publish-hex.yml` manually with `workflow_dispatch`.

### One-Time Hex Publish Automation Setup

1. Generate a Hex API key scoped for publishing:

```bash
mix hex.user key generate --key-name github-actions-publish --permission api:write
```

2. In GitHub repository settings, create secret `HEX_API_KEY`.
3. (Recommended) Create environment `hex-publish` and attach `HEX_API_KEY` there.
4. (Recommended) Add required reviewers to `hex-publish` environment for release gating.

Manual fallback commands (if automation is unavailable):

```bash
mix hex.publish
mix hex.publish docs
```

## Need Help?

If you are unsure where to implement a change:

- API and behavior: component module in `lib/cinder_ui/components/**`
- docs examples/static pages: `dev/lib/cinder_ui/docs/catalog.ex` and docs build task
- browser behavior regressions: `demo/tests/browser/**`

Open a draft PR early for architecture feedback.
