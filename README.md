# Cinder UI

[![CI](https://github.com/levibuzolic/cinder_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/levibuzolic/cinder_ui/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/cinder_ui.svg)](https://hex.pm/packages/cinder_ui)

[shadcn/ui](https://ui.shadcn.com/docs) components for Phoenix + LiveView.

Cinder UI is a Hex-oriented component library that ports [shadcn/ui](https://ui.shadcn.com/docs) design patterns, classes, tokens, and compositional structure into Elixir function components.

## Installation

### Prerequisites

You need an existing Phoenix 1.7+ project. If you don't have one yet:

```bash
mix phx.new my_app
cd my_app
```

### 1. Set up Tailwind CSS

Cinder UI requires Tailwind CSS v4+. New Phoenix projects generated with `mix phx.new` include Tailwind by default — if yours already has it, skip to [step 2](#2-add-cinder-ui).

Add the Tailwind plugin to your dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
    # ...
  ]
end
```

Configure Tailwind in `config/config.exs`:

```elixir
config :tailwind,
  version: "4.1.12",
  my_app: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]
```

Add the Tailwind watcher in `config/dev.exs`:

```elixir
config :my_app, MyAppWeb.Endpoint,
  watchers: [
    tailwind: {Tailwind, :install_and_run, [:my_app, ~w(--watch)]}
  ]
```

Add Tailwind to the deployment alias in `mix.exs`:

```elixir
defp aliases do
  [
    "assets.deploy": [
      "tailwind my_app --minify",
      "esbuild my_app --minify",
      "phx.digest"
    ]
  ]
end
```

Install Tailwind and fetch dependencies:

```bash
mix deps.get
mix tailwind.install
```

Set up `assets/css/app.css`:

```css
@import "tailwindcss";
```

If your `assets/js/app.js` imports CSS (`import "../css/app.css"`), remove that line — Tailwind handles CSS compilation separately.

### 2. Add Cinder UI

Add the dependency to your `mix.exs`:

```elixir
defp deps do
  [
    {:cinder_ui, "~> 0.1.0"},
    # Optional but recommended — required for the <.icon /> component
    {:lucide_icons, "~> 2.0"},
    # ...
  ]
end
```

Fetch dependencies:

```bash
mix deps.get
```

### 3. Run the installer

Cinder UI includes a Mix task that sets up CSS, JavaScript hooks, and Tailwind plugins automatically:

```bash
mix cinder_ui.install
```

This will:

- Copy `cinder_ui.css` into `assets/css/` (theme variables and dark mode)
- Copy `cinder_ui.js` into `assets/js/` (LiveView hooks for interactive components)
- Update `assets/css/app.css` with:
  - `@source "../../deps/cinder_ui";` — so Tailwind scans component classes
  - `@import "./cinder_ui.css";` — loads theme tokens
- Update `assets/js/app.js` to merge `CinderUIHooks` into your LiveView hooks
- Install the `tailwindcss-animate` npm package

The installer auto-detects your package manager (npm, pnpm, yarn, or bun). To specify one explicitly:

```bash
mix cinder_ui.install --package-manager pnpm
```

To re-run without overwriting customized files:

```bash
mix cinder_ui.install --skip-existing
```

To only (re)copy `cinder_ui.css` and `cinder_ui.js` without patching `app.css`/`app.js`:

```bash
mix cinder_ui.install --skip-patching
```

### 4. Configure your app

Add `use CinderUI` to your app's `html_helpers` in `lib/my_app_web.ex`:

```elixir
defp html_helpers do
  quote do
    use Phoenix.Component
    use CinderUI
    # ...
  end
end
```

#### Existing projects with CoreComponents

Phoenix generates a `CoreComponents` module with functions like `button/1`, `input/1`, `table/1`, `flash/1`, `card/1`, and `label/1` that overlap with Cinder UI components. Cinder UI provides replacements for all of these.

**Recommended: Remove conflicting CoreComponents**

The cleanest approach is to delete the overlapping functions (`button/1`, `card/1`, `flash/1`, `flash_group/1`, `input/1`, `label/1`, `table/1`, and `icon/1`) from your `CoreComponents` module and let Cinder UI's versions take over. This gives you a single, consistent component API with no namespace prefixes needed. If your `CoreComponents` only contains the default Phoenix-generated functions, you can remove the module entirely and replace `import MyAppWeb.CoreComponents` with `use CinderUI` in your `html_helpers`.

If you'd prefer to keep your existing CoreComponents alongside Cinder UI, you have several options:

**Option A: Exclude conflicting components**

Use the `except` option to skip components that conflict with your `CoreComponents`:

```elixir
use CinderUI, except: [:button, :card, :flash, :flash_group, :input, :label, :table]
```

Excluded components are still available via the `CinderUI.UI` facade (see Option B) or
their full module path (e.g., `<CinderUI.Components.Actions.button>`).

**Option B: Use the `CinderUI.UI` facade**

Alias the facade module for zero-conflict namespaced access to every component:

```elixir
alias CinderUI.UI
```

Then use components with the `UI.` prefix:

```heex
<UI.button>Click me</UI.button>
<UI.autocomplete id="search" name="q" value="">
  <:option value="foo" label="Foo" />
</UI.autocomplete>
<UI.icon name="chevron-down" class="size-4" />
```

This can be combined with Option A — use `except` for the components that conflict,
and access excluded components via `UI.button`, `UI.input`, etc.

**Option C: Selectively import specific modules**

```elixir
import CinderUI.Components.Actions
import CinderUI.Components.Forms
```

Typography aliases such as `<.h1>` and `<.lead>` live in
`CinderUI.Components.Typography` and are not imported by default because their
short names are more likely to collide with application components. Import them
manually when you want local shorthand components:

```elixir
import CinderUI.Components.Typography
```

Or opt in globally from your web helpers:

```elixir
use CinderUI, typography: true
```

For namespaced access without importing the aliases into the local component
scope:

```elixir
alias CinderUI.Components.Typography
```

```heex
<Typography.h1>Realtime payments need boring interfaces</Typography.h1>
```

### 5. Start building

Start your Phoenix server:

```bash
mix phx.server
# or from the repo root:
./bin/demo --port 4001
```

Try a component in any template:

```heex
<.button>Click me</.button>
```

## Typography Recipes

`typography/1` provides a small set of Shadcn-inspired text treatments without
adding a prose renderer or client-side dependency. Variants use the same
Tailwind token classes as the rest of Cinder UI and render semantic tags by
default.

```heex
<article class="max-w-2xl">
  <.typography variant={:h1}>Realtime payments need boring interfaces</.typography>
  <.typography variant={:lead} class="mt-4">
    Operators need clear hierarchy, calm defaults, and copy that survives dense workflows.
  </.typography>
  <.typography>
    Inline values like <.typography variant={:inline_code}>90d</.typography>
    stay aligned with the active theme tokens.
  </.typography>
</article>
```

When you opt in to typography aliases, the same styles are available as named
components:

```heex
<.h1>Realtime payments need boring interfaces</.h1>
<.lead class="mt-4">Operators need clear hierarchy.</.lead>
<.p>Inline values like <.inline_code>90d</.inline_code> stay aligned.</.p>
```

## Forms and Validation

`CinderUI.Components.Forms` supports both simple field wrappers and more explicit
field composition for validated LiveView forms.

Prefer the shorthand `:label` slot for standard labels. Use raw `:label`
content only when you need custom label markup.

Basic field usage:

```heex
<.field>
  <:label for="project-name">Project name</:label>
  <.input id="project-name" name="project[name]" />
  <:description>Visible to your team in dashboards and alerts.</:description>
</.field>
```

Explicit composition with validation messaging:

```heex
<.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
  <.field invalid={@form[:owner].errors != []}>
    <:label for={@form[:owner].id}>Owner</:label>

    <.field_control>
      <.autocomplete
        id={@form[:owner].id}
        name={@form[:owner].name}
        value={@form[:owner].value}
        aria-label="Owner"
      >
        <:option value="levi" label="Levi Buzolic" description="Engineering" />
        <:option value="mira" label="Mira Chen" description="Design" />
        <:empty>No matching teammates.</:empty>
      </.autocomplete>
    </.field_control>

    <.field_description>Pick the teammate responsible for the workspace.</.field_description>
    <.field_error :for={{msg, _opts} <- @form[:owner].errors}>{msg}</.field_error>
  </.field>

  <.button type="submit">Save</.button>
</.form>
```

`autocomplete/1` keeps the last committed selection until the user confirms a
new option. Typing implicitly highlights the first visible match so `Enter`
accepts it, while `Escape` or clicking away restores the prior selection.

Custom label markup remains available when you need richer label content:

```heex
<.field>
  <:label>
    <.field_label>
      <.label for="workspace-name">Workspace name</.label>
      <span class="text-muted-foreground text-xs">Shown in team switchers.</span>
    </.field_label>
  </:label>
  <.input id="workspace-name" name="workspace[name]" />
</.field>
```

Available field helpers:

- `field/1`
- `field_label/1`
- `field_control/1`
- `field_description/1`
- `field_message/1`
- `field_error/1`
- `input/1`
- `select/1`
- `native_select/1`
- `autocomplete/1`

## Interactive Commands

Interactive components that ship with Cinder UI hooks now share a small command
surface through the `cinder-ui:command` custom event. You can drive that
surface directly from LiveView with `CinderUI.JS`.

For overlay-style components that use the shipped hooks, the current baseline
behavior is:

- `Escape` closes dialogs, drawers, popovers, and dropdown menus
- outside click closes popovers and dropdown menus
- dialog and drawer overlay clicks dismiss the overlay
- hook bindings are refreshed after LiveView-driven DOM updates

Supported commands depend on the component, but the common baseline is:

- `open`
- `close`
- `toggle`
- `focus`

Some input-style components also support:

- `clear`

Current limitation:

- popover and dropdown content still use fixed offset positioning classes such
  as `mt-2`; viewport-aware flipping and collision handling are not implemented yet

LiveView example:

```heex
<button phx-click={CinderUI.JS.open(to: "#account-dialog")}>
  Open dialog
</button>

<button phx-click={CinderUI.JS.clear(to: "#owner-autocomplete")}>
  Clear owner
</button>
```

Raw event example:

```js
const dialog = document.querySelector("[data-slot='dialog']")

dialog?.dispatchEvent(
  new CustomEvent("cinder-ui:command", {
    detail: { command: "open" },
  }),
)
```

If you import `CinderUI` from `assets/js/cinder_ui.js`, you can also dispatch
through the helper:

```js
import { CinderUI, CinderUIHooks } from "./cinder_ui"

CinderUI.dispatchCommand(document.querySelector("[data-slot='select']"), "toggle")
```

## Icons (Optional, Recommended)

`CinderUI.Icons.icon/1` dispatches to [`lucide_icons`](https://hex.pm/packages/lucide_icons).

- Cinder UI reads `lucide_icons.icon_names/0` and caches names automatically.
- Both kebab-case and snake_case icon names are supported.

Example:

```heex
<.icon name="chevron-down" class="size-4" />
<.icon name="loader_circle" class="size-4 animate-spin" />
```

If `lucide_icons` is missing and `<.icon />` is used, Cinder UI raises an error.

## Theming and Style Overrides

Cinder UI uses shadcn-style CSS variables (`--background`, `--foreground`, `--primary`, etc.) and dark mode with `.dark`.

### Configure variables (shadcn-style)

```css
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.54 0.22 262);
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --destructive-foreground: oklch(0.985 0 0);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
  --radius: 0.75rem;
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --primary: oklch(0.72 0.18 262);
  --primary-foreground: oklch(0.205 0 0);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --accent: oklch(0.269 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.704 0.191 22.216);
  --destructive-foreground: oklch(0.985 0 0);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);
}
```

Set your preferred corner scale by changing `--radius`; component classes (`rounded-md`, `rounded-lg`, etc.) derive from that value through the Tailwind token mapping in `assets/css/cinder_ui.css`.

## API Docs

The docs site is the source of truth for component coverage, examples, and current behavior. Every component module also includes in-source docs and usage examples. Generate docs with:

```bash
mix docs
```

## Feasibility Notes

A subset of shadcn components rely on browser-first stacks (Radix primitives, complex keyboard navigation, chart engines, or heavy client state). For these, Cinder UI provides either progressive LiveView hook behavior or a scaffold component with stable API + styling.

## Attribution and Third-Party Notices

Cinder UI is built on the shoulders of giants, leveraging the awesome work from these projects:

- [shadcn/ui](https://ui.shadcn.com/docs) ([GitHub](https://github.com/shadcn-ui/ui))
- [Tailwind CSS](https://tailwindcss.com/) ([GitHub](https://github.com/tailwindlabs/tailwindcss))
- [tailwindcss-animate](https://github.com/jamiebuilds/tailwindcss-animate)
- [lucide_icons](https://hex.pm/packages/lucide_icons) ([GitHub](https://github.com/zoedsoupe/lucide_icons))
- [Lucide Icons](https://lucide.dev/icons/)

Thank you to the maintainers and contributors.

For third-party license details and links to upstream license texts, see: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for contributor setup, quality gates, testing, release workflow, and docs/site build maintenance.

## License

MIT
