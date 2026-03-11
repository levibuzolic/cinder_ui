# Cinder UI Roadmap

AI agent task list organized as sequential phases. Each phase is a self-contained
unit of work that can be completed in a single session. Phases are ordered by
priority and dependency — complete them in order.

**Before starting any phase:** Read `CLAUDE.md` for project conventions.
**After completing a phase:** Run `mix compile --warnings-as-errors` and `mix test`
from the root, then `mix compile --warnings-as-errors` from `demo/`. Commit with
a descriptive message referencing the phase.

---

## Phase 1: Quick Wins (code quality, no behavior changes)

Small fixes that reduce tech debt. Each is independent — can be done in parallel.

- [x] 1.1 **Unify HEEx syntax** — Convert remaining `<%= %>` to `{}` syntax in `overlay.ex` (lines 586-614), `layout.ex` (lines 614-676), `navigation.ex` (lines 544-553), `data_display.ex` (line 647)
- [x] 1.2 **Remove redundant disabled class in dropdown_menu** — `overlay.ex` items apply both `disabled` HTML attr and manual `pointer-events-none opacity-50` class. The HTML attr already triggers Tailwind `disabled:` utilities. Remove the manual class
- [x] 1.3 **Remove dead switch thumb_position case** — `forms.ex` lines 459-463: both `:sm` and `:default` return the same value. Collapse to a single constant
- [x] 1.4 **Consistent aria-label casing** — Standardize to `aria-label="Close"` (capitalized) on flash close button (`feedback.ex`) to match dialog (`overlay.ex`)
- [x] 1.5 **Input: add min/max to rest includes** — `forms.ex` input `@rest` include list omits `min` and `max`, needed for number/date inputs
- [x] 1.6 **Slider: accept float values** — `forms.ex` slider uses `attr :value, :integer`, change to `:any` or `:float`
- [x] 1.7 **Radio group: add per-option disabled** — Add `disabled` attribute to `forms.ex` radio_group option slot

## Phase 2: Accessibility — ARIA attributes

Add missing ARIA roles and attributes. Reference the WAI-ARIA Authoring Practices
for each pattern. These are template-only changes (no JS).

- [x] 2.1 **Tabs** — `navigation.ex`: add `role="tablist"` on list, `role="tab"` on triggers with `aria-selected`, `role="tabpanel"` on content panels with `aria-labelledby`
- [x] 2.2 **Dialog/Sheet/Drawer** — `overlay.ex`: generate stable ids for title and description elements, add `aria-labelledby` and `aria-describedby` on the dialog container
- [x] 2.3 **Dropdown menu** — `overlay.ex`: add `role="menu"` on content, `role="menuitem"` on items
- [x] 2.4 **Tooltip** — `overlay.ex`: add `role="tooltip"` and `id` on tooltip content, `aria-describedby` on trigger
- [x] 2.5 **Autocomplete** — `forms.ex`: add `role="combobox"` on the input element
- [x] 2.6 **Carousel** — `advanced.ex`: add `aria-label` on prev/next buttons, `aria-roledescription="carousel"` on root, `aria-roledescription="slide"` on items
- [x] 2.7 **Hover card** — `overlay.ex`: add `group-focus-within:block` alongside `group-hover:block` for keyboard access

## Phase 3: Flash / Alert rework

- [x] 3.1 **Investigate alert grid alignment** — The alert grid layout (`has-[>svg]:grid-cols-[...]`) doesn't align icon+title correctly when used inside flash. Debug this in the browser and fix the root cause in `feedback.ex` alert component
- [x] 3.2 **Rework flash to use alert/1** — Once 3.1 is resolved, replace the flash flex layout with `<.alert>` internally (remove the TODO comment in `feedback.ex`)
- [x] 3.3 **Add flash kinds: :success and :warning** — Extend `feedback.ex` flash to support `:success` and `:warning` with appropriate colors and icons
- [x] 3.4 **Add alert variants: :success and :warning** — Extend `@alert_variants` map with matching styles

## Phase 4: Forms completeness

- [x] 4.1 **field_control: cover all controls** — `forms.ex` `field_control/1` cascades invalid styling but misses `native-select`, `combobox-input`, `switch`, `checkbox`, `radio-group-item`. Add data-slot selectors for each
- [x] 4.2 **Input OTP: implement JS hook** — Create `CuiInputOtp` hook in `priv/templates/cinder_ui.js` with auto-advance on input, backspace-to-previous, paste handling
- [x] 4.3 **Input OTP: add separator support** — Add a `separator` slot or `groups` attr to `forms.ex` input_otp for visual separators between digit groups

## Phase 5: JS Hook improvements

Each task requires editing `priv/templates/cinder_ui.js` (the source of truth).
After editing, run `mix assets.build` from `demo/` to regenerate copies.

- [x] 5.1 **Menubar: implement CuiMenubar hook** — Click-to-open menus, arrow-left/right between menus, arrow-down into items, Escape to close. Update `overlay.ex` to add `phx-hook="CuiMenubar"`
- [x] 5.2 **Autocomplete: add Home/End key support** — `CuiAutocomplete` only handles ArrowDown/Up/Enter/Escape. Add Home and End to match `CuiSelect`
- [x] 5.3 **Select/Dropdown: add typeahead** — Pressing a letter key should jump to the first matching item. Implement in `createItemHighlighter` or per-hook

## Phase 6: Component improvements

- [x] 6.1 **Avatar: image error fallback** — Add `onerror` to the `<img>` in `data_display.ex` that hides the image and shows the fallback initials
- [x] 6.2 **Avatar group count: size prop** — `data_display.ex` `avatar_group_count/1` is hardcoded `size-8`. Add a `size` attr or use `group-has-data-[size=*]` responsive classes like shadcn
- [x] 6.3 **Code block: copy button** — Add a copy-to-clipboard button to `data_display.ex` code_block. May need a small JS hook
- [x] 6.4 **Button group: merge borders** — Implement negative margin + z-index pattern in `actions.ex` button_group to merge adjacent button borders like shadcn
- [x] 6.5 **Sidebar: use CSS variables** — Update `advanced.ex` sidebar to use `bg-sidebar`, `text-sidebar-foreground` etc. instead of hardcoded `bg-muted/20`
- [x] 6.6 **Carousel: autoplay and indicators** — Extend `CuiCarousel` hook with autoplay interval, pause-on-hover, dot indicator rendering

## Phase 7: CSS fixes

- [x] 7.1 **Reconcile dark mode** — `cinder_ui.css` defines `@custom-variant dark` for `[data-theme=dark]` but CSS variables switch under `.dark` class. Make these consistent
- [ ] 7.2 **Map chart/sidebar CSS vars to Tailwind** — Add `--chart-1` through `--chart-5` and `--sidebar-*` variables to `@theme inline` so they work as `bg-chart-1` etc.
- [ ] 7.3 **prefers-reduced-motion** — Add `motion-reduce:` overrides for animated components or disable `tailwindcss-animate` transitions when reduced motion is preferred

## Phase 8: Testing

- [ ] 8.1 **Expand unit tests** — Add structural assertions beyond `data-slot` presence for: button_group, toggle_group, accordion, collapsible, code_block, avatar_group, popover, tooltip, hover_card, alert_dialog, menubar, pagination, combobox, carousel, chart, sidebar, checkbox, radio_group, slider, input_otp, label, field_label, field_description, field_message
- [ ] 8.2 **Playwright interaction tests** — Add browser tests for: dialog open/close, select keyboard navigation, autocomplete filtering, dropdown menu, tabs switching, carousel prev/next
- [ ] 8.3 **JS hook unit tests** — Set up a test harness for client-side behavior in `priv/templates/cinder_ui.js` (consider vitest or playwright component testing), covering hooks like `CuiAutocomplete`, `CuiSelect`, `CuiInputOtp`, `CuiMenubar`, `CuiCarousel`, and `CuiResizable`

## Phase 9: Install task improvements

- [ ] 9.1 **Detect `bun.lock`** — `lib/mix/tasks/cinder_ui.install.ex` line 258 only checks `bun.lockb`. Add `bun.lock` detection for Bun v1.1+
- [ ] 9.2 **Handle inline Hooks** — `inject_hooks_merge/1` doesn't handle `const liveSocket = new LiveSocket(...)` with Hooks defined inline. Add detection for this pattern
- [ ] 9.3 **Add --dry-run option** — Print what would change without writing files

## Phase 10: New components

Lower priority. Each is a standalone task.

- [ ] 10.1 **Context Menu** — Right-click context menu with JS hook for positioning and keyboard navigation
- [ ] 10.2 **Toast/Sonner** — Stacking toast notification system with auto-dismiss, progress, and swipe-to-dismiss
- [ ] 10.3 **Date Picker** — Compose Calendar + Popover with full date selection (single, range), month/year navigation
- [ ] 10.4 **Data Table** — Compose table/1 with sortable headers, filtering, and pagination. LiveView-friendly with server-side data handling
- [ ] 10.5 **Number Field** — Increment/decrement input with keyboard support and min/max/step
- [ ] 10.6 **File Upload / Dropzone** — Styled drag-and-drop zone wrapping Phoenix `allow_upload/3`
- [ ] 10.7 **Stepper** — Multi-step progress indicator for wizard flows
- [ ] 10.8 **Calendar: full implementation** — Week/month navigation, single/range/multi select, server state integration

## Phase 11: Documentation

- [ ] 11.1 **Clarify combobox vs autocomplete** — Add "when to use which" guidance to both component docs
- [ ] 11.2 **Fix select README description** — README incorrectly says "native select style variant" for select/1
- [ ] 11.3 **Update resizable status** — Either promote from "In Progress" or document what's specifically incomplete
- [ ] 11.4 **Popover/dropdown positioning** — Document the limitation of hardcoded `mt-2` positioning and plans for viewport-aware placement
