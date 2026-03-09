# Cinder UI

Shadcn-inspired UI components for Phoenix + LiveView.

Cinder UI is a Hex-oriented component library that ports shadcn/ui design patterns, classes, tokens, and compositional structure into Elixir function components.

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

Or selectively import only the modules you need:

```elixir
import CinderUI.Components.Actions
import CinderUI.Components.Forms
```

### 5. Start building

Start your Phoenix server:

```bash
mix phx.server
```

Try a component in any template:

```heex
<.button>Click me</.button>
```

## Forms and Validation

`CinderUI.Components.Forms` supports both simple field wrappers and more explicit
field composition for validated LiveView forms.

Basic field usage:

```heex
<.field>
  <:label><.label for="project-name">Project name</.label></:label>
  <.input id="project-name" name="project[name]" />
  <:description>Visible to your team in dashboards and alerts.</:description>
</.field>
```

Explicit composition with validation messaging:

```heex
<.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
  <.field invalid={@form[:owner].errors != []}>
    <:label>
      <.label for={@form[:owner].id}>Owner</.label>
    </:label>

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

Available field helpers:

- `field/1`
- `field_label/1`
- `field_control/1`
- `field_description/1`
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

Supported commands depend on the component, but the common baseline is:

- `open`
- `close`
- `toggle`
- `focus`

Some input-style components also support:

- `clear`

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

## Component Coverage

Legend:

- `✅ Full`: production-ready server-rendered implementation
- `⚡ Progressive`: server-rendered base with optional LiveView hook enhancement
- `🧱 Scaffold`: layout + API contract ready; full behavior needs host-side JS integration
- `🚧 Not Yet`: intentionally not implemented yet

| shadcn component family | Coverage | Interactivity model | Compatibility / limitations |
| --- | --- | --- | --- |
| Accordion | ✅ Full | Server-rendered | Matches core usage patterns |
| Alert | ✅ Full | Server-rendered | - |
| Alert Dialog | ✅ Full | Server-rendered | - |
| Aspect Ratio | ✅ Full | Server-rendered | - |
| Avatar | ✅ Full | Server-rendered | - |
| Badge | ✅ Full | Server-rendered | - |
| Breadcrumb | ✅ Full | Server-rendered | - |
| Button / Button Group | ✅ Full | Server-rendered | - |
| Calendar | 🧱 Scaffold | Static shell | Full date-picker behavior requires additional JS |
| Carousel | ⚡ Progressive | Server + hooks | Hook layer drives controls/slide state |
| Chart | 🧱 Scaffold | Static shell | Requires external chart engine integration |
| Checkbox | ✅ Full | Server-rendered | - |
| Collapsible | ✅ Full | Server-rendered | - |
| Combobox | ⚡ Progressive | Server + hooks | Hook layer handles filtering/select behavior |
| Command | ✅ Full | Server-rendered | - |
| Context Menu | 🚧 Not Yet | N/A | JS-heavy semantics still pending |
| Dialog | ⚡ Progressive | Server + hooks | Hook layer handles open/close behavior |
| Drawer | ⚡ Progressive | Server + hooks | Hook layer handles panel/overlay behavior |
| Dropdown Menu | ⚡ Progressive | Server + hooks | Hook layer handles menu toggling |
| Empty | ✅ Full | Server-rendered | - |
| Field / Form primitives | ✅ Full | Server-rendered | - |
| Hover Card | ✅ Full | Server-rendered | - |
| Input Group | ✅ Full | Server-rendered | - |
| Input OTP | ✅ Full | Server-rendered | - |
| Input | ✅ Full | Server-rendered | - |
| Icons (`CinderUI.Icons.icon/1`) | ✅ Full | Server-rendered | Requires optional `lucide_icons` dependency |
| Item | ✅ Full | Server-rendered | - |
| Kbd | ✅ Full | Server-rendered | - |
| Label | ✅ Full | Server-rendered | - |
| Menubar | ⚡ Progressive | Server + hooks | Hook layer handles interactive menu behavior |
| Menu | ✅ Full | Server-rendered | daisyUI-inspired navigation list primitive |
| Navigation Menu | ✅ Full | Server-rendered | - |
| Pagination | ✅ Full | Server-rendered | - |
| Popover | ⚡ Progressive | Server + hooks | Hook layer handles open/close behavior |
| Progress | ✅ Full | Server-rendered | - |
| Radio Group | ✅ Full | Server-rendered | - |
| Resizable | 🚧 In Progress | Not ready for use | `resizable/1` is currently in progress and not ready for production use |
| Scroll Area | ✅ Full | Server-rendered | - |
| Select | ✅ Full | Server-rendered | Implemented as native select style variant |
| Separator | ✅ Full | Server-rendered | - |
| Sheet | ✅ Full | Server-rendered | Drawer alias semantics |
| Sidebar | 🧱 Scaffold | Static shell | Complex interactions require host-side logic |
| Skeleton | ✅ Full | Server-rendered | - |
| Slider | ✅ Full | Server-rendered | Native range input style |
| Sonner | 🚧 Not Yet | N/A | Not implemented; toast support planned for future release |
| Toast | 🚧 Not Yet | N/A | Not implemented; flash/toast API is intentionally deferred |
| Spinner | ✅ Full | Server-rendered | - |
| Switch | ✅ Full | Server-rendered | - |
| Table | ✅ Full | Server-rendered | - |
| Tabs | ✅ Full | Server-rendered | - |
| Textarea | ✅ Full | Server-rendered | - |
| Toggle / Toggle Group | ✅ Full | Server-rendered | - |
| Tooltip | ✅ Full | Server-rendered | - |

## API Docs

Every component module includes in-source docs and usage examples. Generate docs with:

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
