# Competitive Audit Roadmap

Long-lived roadmap for closing the gap between `cinder_ui` and the strongest ideas found in:

- SaladUI: https://salad-storybook.fly.dev/welcome
- Fluxon: https://fluxonui.com/
- daisyUI: https://daisyui.com/

This document is intentionally written as a working backlog. It should be updated as tasks are completed, deprioritized, or replaced.

## Goal

Make `cinder_ui` an exceptionally high-quality Phoenix + LiveView component library by:

- keeping a Phoenix-first API surface
- matching or exceeding the best practical UX and accessibility ideas from peer libraries
- choosing interaction models that work well with LiveView state and patches
- improving installation, theming, documentation, and test coverage alongside component work

## Non-Goals

- Do not implement RTL support unless a maintainer explicitly asks for it.
- Do not chase parity for every component just because another library ships it.
- Do not copy JavaScript-heavy patterns from non-Phoenix libraries when native HTML or LiveView-friendly patterns are enough.

## How To Use This Roadmap

When resuming work:

1. Pick the next unchecked item from the current phase.
2. Read the "Why this matters" and "Acceptance criteria" for that item.
3. Implement the library change.
4. Update docs/examples in the static catalog and demo.
5. Add or update tests.
6. Mark progress here with date and short notes.

Suggested status markers:

- `[ ]` not started
- `[-]` in progress
- `[x]` complete
- `[~]` intentionally deferred

## Quality Bar

Before calling a component "done", it should usually satisfy all of the following:

- typed `attr` and `slot` API with predictable assigns
- clear server-controlled and client-enhanced usage patterns
- keyboard behavior defined and tested where the component is interactive
- accessible markup and naming
- docs examples for default, advanced, and edge-case usage
- demo coverage
- browser tests for interactions and visual snapshots where appropriate
- no hidden coupling to a specific app layout or asset pipeline beyond documented install steps

## Strategic Takeaways From The Audit

### SaladUI

Strongest ideas to borrow:

- LiveView-oriented command patterns for client/server component control
- richer form composition primitives instead of a single field wrapper
- a broad shadcn-aligned surface area

Caveat:

- useful architectural ideas, but less compelling than Fluxon as the benchmark for polished interaction details

### Fluxon

Strongest ideas to borrow:

- high-quality interactive form controls
- explicit server/client control for overlays and drawers
- hidden native inputs for custom controls so forms still submit correctly
- broader coverage of date/time, select, autocomplete, nav, and stateful components
- evidence of ongoing bug-fixing around focus, clipping, change events, and patch interoperability

This is the primary quality benchmark for interactive Phoenix components.

### daisyUI

Strongest ideas to borrow:

- theme ergonomics and semantic token discipline
- practical low-JS and native HTML patterns (`details`, `<dialog>`, Popover API)
- useful utility-style component ideas for empty states, stats, steps, timeline, validator, status, and similar patterns

Caveat:

- treat daisyUI as a source of ideas, not as an architectural template for `cinder_ui`

## Current Gaps In cinder_ui

Highest-impact gaps identified during the audit:

- `combobox/1` is currently a lightweight filterable dropdown and lacks keyboard navigation, hidden form backing, multi-select, and richer state control.
- interactive hooks are mostly visibility toggles rather than a reusable command model.
- form composition is less expressive than the better Phoenix-first libraries.
- date and time input primitives are missing.
- some practical navigation, state, and utility components are missing.
- installer and theming are solid, but there is room for better presets, modes, and docs.

## Phase 0: Working Rules

- [ ] Keep this roadmap updated as work lands.
- [ ] For every interactive component, document the intended state model before implementation:
  server-controlled, client-enhanced, or hybrid.
- [ ] Prefer native HTML primitives when they provide the behavior with less complexity.
- [ ] Add browser tests for interactive behavior before considering a phase complete.
- [ ] Preserve Phoenix-first ergonomics over React-style API mirroring.

## Phase 1: Forms And Selection

Why this matters:

This is the highest-value area. The current library surface is good enough for simple cases, but it does not yet feel best-in-class for real app forms.

### 1.1 Split native and custom select responsibilities

- [x] Rename the current native implementation to `native_select/1`.
- [x] Make `select/1` the custom/select-listbox component name.
- [x] Migration work is intentionally skipped until public release.

Acceptance criteria:

- native and custom select use distinct names and documented use-cases
- docs explain when to use each
- current users have a clear upgrade story

### 1.2 Build a real custom select

- [x] Add `select/1` as a custom interactive select primitive.
- [x] Support trigger/content/item composition.
- [x] Support placeholder, disabled state, clearable state, grouped items, and empty state.
- [x] Back the component with a hidden input or select so forms submit correctly.
- [x] Add keyboard navigation and selection behavior.

Borrow from:

- Fluxon `Select`
- shadcn `Select`

Acceptance criteria:

- works in forms without custom glue
- keyboard navigation is covered by browser tests
- server-controlled and client-controlled examples are both documented

### 1.3 Add `autocomplete/1`

- [x] Separate autocomplete from select semantics.
- [x] Support client-side filtering first.
- [x] Add a documented server-search pattern for LiveView.
- [x] Support empty state, loading state, and no-results messaging.

Borrow from:

- Fluxon `Autocomplete`
- current combobox work as a starting point, but not the final API

Acceptance criteria:

- keyboard navigation, highlighted option state, and selection are tested
- component can submit a value through a form-friendly backing input

### 1.4 Upgrade form composition primitives

- [x] Expand the current field model into richer subcomponents or equivalent slots:
  control, description, message, and error presentation
- [x] Ensure error state styling can flow from the field wrapper to the control
- [x] Provide examples for Phoenix forms and validation errors

Borrow from:

- SaladUI form composition
- Fluxon form ergonomics

Acceptance criteria:

- forms with validation can be expressed without ad hoc wrapper markup
- docs cover plain HTML input and higher-level controls inside the same form system

## Phase 2: Interaction Architecture

Why this matters:

The current JS hooks work, but they are too bespoke. Better libraries make interactive behavior predictable, composable, and patch-safe.

### 2.1 Introduce a command model for interactive components

- [x] Define a consistent command vocabulary for interactive primitives:
  `open`, `close`, `toggle`, `focus`, and component-specific commands where justified
- [x] Decide whether commands live in JS helpers, LiveView helpers, or both
- [x] Standardize event and data-attribute naming

Borrow from:

- SaladUI command dispatch ideas
- Fluxon `on_open` / `on_close` style control

Acceptance criteria:

- dialogs, drawers/sheets, popovers, and dropdowns share a consistent control story
- docs explain the command model clearly
- both JS and LiveView have first-class helpers for dispatching commands

### 2.2 Improve overlay behavior quality

- [-] Add focus management expectations for dialog-like components.
- [x] Review dismissal behavior: close button, escape key, outside click, server-controlled state updates.
- [x] Ensure patch-safe behavior when LiveView re-renders content.
- [x] Revisit `drawer` vs `sheet` semantics and split them if needed.

Acceptance criteria:

- keyboard dismissal and focus behavior are tested
- server-controlled examples do not fight client hooks
- docs state what is guaranteed and what is optional enhancement

### 2.3 Improve listbox-like component quality

- [x] Add active descendant or equivalent keyboard model where appropriate.
- [x] Ensure highlighted item state is exposed for styling.
- [x] Handle empty, loading, and disabled item states consistently across select/autocomplete/command-like components.

Acceptance criteria:

- selection components behave consistently
- disabled and empty states are documented and tested

## Phase 3: Date And Time Inputs

Why this matters:

Date and time pickers are a major capability gap compared with the best Phoenix UI libraries.

### 3.1 Add `date_picker/1`

- [ ] Build a practical date picker with form integration.
- [ ] Decide whether the base calendar remains mostly presentational or becomes a stronger primitive.
- [ ] Support controlled value, disabled dates, and formatting hooks.

### 3.2 Add `date_range_picker/1`

- [ ] Support selecting a start and end date.
- [ ] Handle partial selection and clear display states.

### 3.3 Evaluate `date_time_picker/1`

- [ ] Only build this after `date_picker/1` is stable.
- [ ] Decide whether time selection belongs in the same component or as composition with separate primitives.

Borrow from:

- Fluxon date picker family

Acceptance criteria:

- form submission semantics are clear
- examples cover LiveView forms and plain values
- browser tests cover selection flows

## Phase 4: Coverage And Completeness

Why this matters:

Once forms and interactions are strong, these components will make the library feel substantially more complete.

### 4.1 High-priority missing components

- [ ] `context_menu/1`
- [ ] `navlist/1` or equivalent vertical navigation family
- [ ] notification layer (`sonner`-style or equivalent)
- [ ] richer `loading` family beyond `spinner/1`

### 4.2 Practical utility components inspired by daisyUI

- [ ] `stats/1`
- [ ] `steps/1`
- [ ] `timeline/1`
- [ ] `status/1`
- [ ] `swap/1`
- [ ] `validator/1`
- [ ] `diff/1`
- [ ] `dock/1`

Acceptance criteria:

- each new component earns its place through practical Phoenix app use-cases
- avoid adding novelty components without a clear docs/demo story

## Phase 5: Theming, Tokens, And Setup

Why this matters:

The current setup is good. This phase is about making it easier to adopt, customize, and maintain at scale.

### 5.1 Strengthen the theme contract

- [ ] Document the full token surface shipped by `cinder_ui.css`.
- [ ] Decide which tokens are stable public API.
- [ ] Add one or more supported preset themes.
- [ ] Add guidance for host-app overrides and scoping.

Borrow from:

- daisyUI theme ergonomics
- current shadcn token model

### 5.2 Improve installer ergonomics

- [ ] Add a dry-run mode.
- [ ] Add clearer reporting for changed files.
- [ ] Consider optional installation modes:
  CSS-only, CSS+JS, or selected component support packages
- [ ] Consider theme preset selection during install.

Acceptance criteria:

- installer output is safe and understandable for repeat runs
- advanced teams can adopt only the pieces they need

### 5.3 Document LiveView patch interoperability

- [ ] Add docs for any required `onBeforeElUpdated` or similar patterns if richer interactivity needs it.
- [ ] Document when hooks own client state and when the server owns state.
- [ ] Make patch behavior explicit in interactive component docs.

## Phase 6: Documentation And Testing Excellence

Why this matters:

High-quality components without high-quality docs and tests still feel risky to consumers.

### 6.1 Raise docs quality

- [ ] Every public interactive component should have:
  default usage, controlled usage, edge cases, and form integration examples
- [ ] Add "When to use this vs ..." guidance for overlapping components.
- [ ] Add implementation notes where behavior is intentionally simplified or native-first.

### 6.2 Raise browser test quality

- [ ] Add interaction tests for keyboard behavior, open/close state, focus, and form submission.
- [ ] Add targeted visual tests for overlays, menus, and form states.
- [ ] Add regression tests when fixing interaction bugs.

### 6.3 Create a release-readiness checklist for interactive changes

- [ ] Define a reusable checklist for:
  docs, unit tests, browser tests, screenshots, migration notes, and demo coverage

## Candidate Work Queue

Recommended execution order:

1. split `native_select` and custom `select`
2. build `autocomplete`
3. expand form composition primitives
4. introduce command model for interactive components
5. improve dialog/popover/dropdown/drawer behavior
6. add date picker
7. add notification layer
8. add `navlist`
9. add utility completeness components from daisyUI
10. improve installer and theme presets

## Notes On Existing cinder_ui Architecture

Current strengths worth preserving:

- Tailwind v4 CSS-first setup
- generated installer task
- semantic token layer in shipped CSS
- low-dependency approach
- LiveView hooks that are simple to understand

Current constraints to revisit carefully:

- bespoke hook behavior per component
- limited keyboard and focus behavior in interactive widgets
- shallow form integration for custom controls

## Progress Log

Use this section to record actual work as it lands.

### 2026-03-09

- Initial competitive audit completed.
- Sources reviewed: SaladUI, Fluxon, daisyUI, plus current `cinder_ui` implementation.
- Primary benchmark selected for interactive quality: Fluxon.
- Primary benchmark selected for LiveView command ideas: SaladUI.
- Primary benchmark selected for theme ergonomics and utility component ideas: daisyUI.
- Split native and custom select responsibilities.
- Added a first custom `select/1` primitive with hidden form backing and browser-tested keyboard selection behavior.
- Added a first `autocomplete/1` primitive with client-side filtering, hidden form backing, and focused browser coverage.
- Expanded `field/1` with explicit field subcomponents and shared invalid-state styling hooks for inputs, select, and autocomplete.
- Added Phoenix validation examples for the expanded field composition model in module docs and the README.
- Added a shared `cinder-ui:command` event model plus JS helper exports for commandable interactive components.

## Source Links

- SaladUI Storybook: https://salad-storybook.fly.dev/welcome
- SaladUI docs: https://hexdocs.pm/salad_ui/readme.html
- SaladUI beta API: https://hexdocs.pm/salad_ui/1.0.0-beta.3/api-reference.html
- SaladUI form docs: https://hexdocs.pm/salad_ui/1.0.0-beta.3/SaladUI.Form.html
- SaladUI LiveView commands: https://hexdocs.pm/salad_ui/1.0.0-beta.3/SaladUI.LiveView.html
- Fluxon overview: https://docs.fluxonui.com/overview.html
- Fluxon changelog: https://docs.fluxonui.com/changelog.html
- Fluxon select docs: https://docs.fluxonui.com/2.2.1/Fluxon.Components.Select.html
- Fluxon autocomplete docs: https://docs.fluxonui.com/Fluxon.Components.Autocomplete.html
- Fluxon date picker docs: https://docs.fluxonui.com/Fluxon.Components.DatePicker.html
- Fluxon navlist docs: https://docs.fluxonui.com/2.3.0/Fluxon.Components.Navlist.html
- daisyUI docs: https://daisyui.com/
- daisyUI dropdown docs: https://daisyui.com/components/dropdown/
- daisyUI modal docs: https://daisyui.com/components/modal/
- daisyUI scalable component library notes: https://daisyui.com/pages/scalable-component-library/
