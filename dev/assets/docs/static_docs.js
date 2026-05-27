import { CinderUIHooks } from "./cinder_ui.js"

/**
 * Static docs interactivity — vanilla JS replacements for CinderUI LiveView
 * hooks, used when the docs are exported as static HTML (GitHub Pages, mix
 * cinder_ui.docs.build). The live demo app uses the real hooks via app.js.
 *
 * Loaded as type="module" so all declarations are scoped automatically.
 */

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/** Shorthand for querySelectorAll that returns a real Array. */
const qs = (root, selector) => Array.from(root.querySelectorAll(selector))

/** Escape user-supplied text before inserting into innerHTML. */
const escapeHtml = (value) =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")

/**
 * Show/hide an element by toggling the `hidden` class and setting
 * `data-state` to "open" or "closed" (used by CSS animations).
 */
const toggleVisibility = (el, visible) => {
  if (!el) return
  el.classList.toggle("hidden", !visible)
  el.dataset.state = visible ? "open" : "closed"
}

export const shouldMountStaticHooks = () =>
  !(window.liveSocket && typeof window.liveSocket.connect === "function")

export const mountStaticHook = (el) => {
  const hookName = el.getAttribute("phx-hook")
  if (!hookName) return false

  const definition = CinderUIHooks[hookName]
  if (!definition) return false

  const instance = Object.create(definition)
  instance.el = el
  instance.pushEvent = () => Promise.resolve()
  instance.pushEventTo = () => Promise.resolve()
  instance.handleEvent = () => {}
  instance.removeHandleEvent = () => {}
  instance.liveSocket = null
  instance.__static = true
  el.__cuiStaticHook = instance
  instance.mounted?.()
  return true
}

export const initializeStaticHooks = () => {
  if (!shouldMountStaticHooks()) return

  const hookElements = qs(document, "[phx-hook]")
  const usedHooks = Array.from(new Set(hookElements.map((el) => el.getAttribute("phx-hook")).filter(Boolean)))
  const availableHooks = Object.keys(CinderUIHooks)
  const missingHooks = usedHooks.filter((name) => !availableHooks.includes(name))

  window.CinderUIStaticHookNames = availableHooks
  window.CinderUIStaticUsedHooks = usedHooks
  window.CinderUIStaticMissingHooks = missingHooks

  if (missingHooks.length > 0) {
    console.warn(`Missing static hook implementations: ${missingHooks.join(", ")}`)
  }

  hookElements.forEach((el) => {
    mountStaticHook(el)
  })
}

const shouldAutoInitializeStaticDocs =
  !globalThis.__CUI_DISABLE_STATIC_DOCS_AUTO_INIT

// ---------------------------------------------------------------------------
// Theme system — persists mode (light/dark/auto), color palette and border
// radius to localStorage and applies them as CSS custom properties.
// ---------------------------------------------------------------------------

const themeStorage = {
  mode: "cui:theme:mode",
  color: "cui:theme:color",
  radius: "cui:theme:radius",
}

// Each color palette overrides the shadcn/ui design tokens for light and dark
// modes. Only the tokens that differ from the default CSS are included.
const themePresets = {
  neutral: {
    light: {
      foreground: "oklch(0.145 0 0)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.145 0 0)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.145 0 0)",
      primary: "oklch(0.205 0 0)",
      "primary-foreground": "oklch(0.985 0 0)",
      secondary: "oklch(0.97 0 0)",
      "secondary-foreground": "oklch(0.205 0 0)",
      muted: "oklch(0.97 0 0)",
      "muted-foreground": "oklch(0.556 0 0)",
      accent: "oklch(0.97 0 0)",
      "accent-foreground": "oklch(0.205 0 0)",
      border: "oklch(0.922 0 0)",
      input: "oklch(0.922 0 0)",
      ring: "oklch(0.708 0 0)",
    },
    dark: {
      background: "oklch(0.145 0 0)",
      foreground: "oklch(0.985 0 0)",
      card: "oklch(0.205 0 0)",
      "card-foreground": "oklch(0.985 0 0)",
      popover: "oklch(0.205 0 0)",
      "popover-foreground": "oklch(0.985 0 0)",
      primary: "oklch(0.922 0 0)",
      "primary-foreground": "oklch(0.205 0 0)",
      secondary: "oklch(0.269 0 0)",
      "secondary-foreground": "oklch(0.985 0 0)",
      muted: "oklch(0.269 0 0)",
      "muted-foreground": "oklch(0.708 0 0)",
      accent: "oklch(0.269 0 0)",
      "accent-foreground": "oklch(0.985 0 0)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.556 0 0)",
    },
  },
  stone: {
    light: {
      foreground: "oklch(0.147 0.004 49.25)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.147 0.004 49.25)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.147 0.004 49.25)",
      primary: "oklch(0.216 0.006 56.043)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.97 0.001 106.424)",
      "secondary-foreground": "oklch(0.216 0.006 56.043)",
      muted: "oklch(0.97 0.001 106.424)",
      "muted-foreground": "oklch(0.553 0.013 58.071)",
      accent: "oklch(0.97 0.001 106.424)",
      "accent-foreground": "oklch(0.216 0.006 56.043)",
      border: "oklch(0.923 0.003 48.717)",
      input: "oklch(0.923 0.003 48.717)",
      ring: "oklch(0.709 0.01 56.259)",
    },
    dark: {
      background: "oklch(0.147 0.004 49.25)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.216 0.006 56.043)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.216 0.006 56.043)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.923 0.003 48.717)",
      "primary-foreground": "oklch(0.216 0.006 56.043)",
      secondary: "oklch(0.268 0.007 34.298)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.268 0.007 34.298)",
      "muted-foreground": "oklch(0.709 0.01 56.259)",
      accent: "oklch(0.268 0.007 34.298)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.553 0.013 58.071)",
    },
  },
  zinc: {
    light: {
      foreground: "oklch(0.141 0.005 285.823)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.141 0.005 285.823)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.141 0.005 285.823)",
      primary: "oklch(0.21 0.006 285.885)",
      "primary-foreground": "oklch(0.985 0 0)",
      secondary: "oklch(0.967 0.001 286.375)",
      "secondary-foreground": "oklch(0.21 0.006 285.885)",
      muted: "oklch(0.967 0.001 286.375)",
      "muted-foreground": "oklch(0.552 0.016 285.938)",
      accent: "oklch(0.967 0.001 286.375)",
      "accent-foreground": "oklch(0.21 0.006 285.885)",
      border: "oklch(0.92 0.004 286.32)",
      input: "oklch(0.92 0.004 286.32)",
      ring: "oklch(0.705 0.015 286.067)",
    },
    dark: {
      background: "oklch(0.141 0.005 285.823)",
      foreground: "oklch(0.985 0 0)",
      card: "oklch(0.21 0.006 285.885)",
      "card-foreground": "oklch(0.985 0 0)",
      popover: "oklch(0.21 0.006 285.885)",
      "popover-foreground": "oklch(0.985 0 0)",
      primary: "oklch(0.92 0.004 286.32)",
      "primary-foreground": "oklch(0.21 0.006 285.885)",
      secondary: "oklch(0.274 0.006 286.033)",
      "secondary-foreground": "oklch(0.985 0 0)",
      muted: "oklch(0.274 0.006 286.033)",
      "muted-foreground": "oklch(0.705 0.015 286.067)",
      accent: "oklch(0.274 0.006 286.033)",
      "accent-foreground": "oklch(0.985 0 0)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.552 0.016 285.938)",
    },
  },
  mauve: {
    light: {
      foreground: "oklch(0.129 0.042 264.695)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.129 0.042 264.695)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.129 0.042 264.695)",
      primary: "oklch(0.208 0.042 265.755)",
      "primary-foreground": "oklch(0.984 0.003 247.858)",
      secondary: "oklch(0.968 0.007 247.896)",
      "secondary-foreground": "oklch(0.208 0.042 265.755)",
      muted: "oklch(0.968 0.007 247.896)",
      "muted-foreground": "oklch(0.554 0.046 257.417)",
      accent: "oklch(0.968 0.007 247.896)",
      "accent-foreground": "oklch(0.208 0.042 265.755)",
      border: "oklch(0.929 0.013 255.508)",
      input: "oklch(0.929 0.013 255.508)",
      ring: "oklch(0.704 0.04 256.788)",
    },
    dark: {
      background: "oklch(0.129 0.042 264.695)",
      foreground: "oklch(0.984 0.003 247.858)",
      card: "oklch(0.208 0.042 265.755)",
      "card-foreground": "oklch(0.984 0.003 247.858)",
      popover: "oklch(0.208 0.042 265.755)",
      "popover-foreground": "oklch(0.984 0.003 247.858)",
      primary: "oklch(0.929 0.013 255.508)",
      "primary-foreground": "oklch(0.208 0.042 265.755)",
      secondary: "oklch(0.279 0.041 260.031)",
      "secondary-foreground": "oklch(0.984 0.003 247.858)",
      muted: "oklch(0.279 0.041 260.031)",
      "muted-foreground": "oklch(0.704 0.04 256.788)",
      accent: "oklch(0.279 0.041 260.031)",
      "accent-foreground": "oklch(0.984 0.003 247.858)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.551 0.027 264.364)",
    },
  },
  olive: {
    light: {
      foreground: "oklch(0.144 0.013 101.487)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.144 0.013 101.487)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.144 0.013 101.487)",
      primary: "oklch(0.206 0.02 106.266)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.967 0.007 83.831)",
      "secondary-foreground": "oklch(0.206 0.02 106.266)",
      muted: "oklch(0.967 0.007 83.831)",
      "muted-foreground": "oklch(0.554 0.027 99.305)",
      accent: "oklch(0.967 0.007 83.831)",
      "accent-foreground": "oklch(0.206 0.02 106.266)",
      border: "oklch(0.928 0.015 100.425)",
      input: "oklch(0.928 0.015 100.425)",
      ring: "oklch(0.704 0.03 99.776)",
    },
    dark: {
      background: "oklch(0.144 0.013 101.487)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.206 0.02 106.266)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.206 0.02 106.266)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.928 0.015 100.425)",
      "primary-foreground": "oklch(0.206 0.02 106.266)",
      secondary: "oklch(0.272 0.024 108.528)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.272 0.024 108.528)",
      "muted-foreground": "oklch(0.704 0.03 99.776)",
      accent: "oklch(0.272 0.024 108.528)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.554 0.027 99.305)",
    },
  },
  mist: {
    light: {
      foreground: "oklch(0.138 0.039 265.975)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.138 0.039 265.975)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.138 0.039 265.975)",
      primary: "oklch(0.193 0.051 262.911)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.965 0.015 263.438)",
      "secondary-foreground": "oklch(0.193 0.051 262.911)",
      muted: "oklch(0.965 0.015 263.438)",
      "muted-foreground": "oklch(0.553 0.04 264.364)",
      accent: "oklch(0.965 0.015 263.438)",
      "accent-foreground": "oklch(0.193 0.051 262.911)",
      border: "oklch(0.925 0.022 264.531)",
      input: "oklch(0.925 0.022 264.531)",
      ring: "oklch(0.703 0.045 263.196)",
    },
    dark: {
      background: "oklch(0.138 0.039 265.975)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.193 0.051 262.911)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.193 0.051 262.911)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.925 0.022 264.531)",
      "primary-foreground": "oklch(0.193 0.051 262.911)",
      secondary: "oklch(0.267 0.042 258.657)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.267 0.042 258.657)",
      "muted-foreground": "oklch(0.703 0.045 263.196)",
      accent: "oklch(0.267 0.042 258.657)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.553 0.04 264.364)",
    },
  },
  taupe: {
    light: {
      foreground: "oklch(0.146 0.01 49.25)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.146 0.01 49.25)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.146 0.01 49.25)",
      primary: "oklch(0.21 0.014 49.269)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.969 0.007 40.998)",
      "secondary-foreground": "oklch(0.21 0.014 49.269)",
      muted: "oklch(0.969 0.007 40.998)",
      "muted-foreground": "oklch(0.554 0.015 49.269)",
      accent: "oklch(0.969 0.007 40.998)",
      "accent-foreground": "oklch(0.21 0.014 49.269)",
      border: "oklch(0.926 0.01 49.269)",
      input: "oklch(0.926 0.01 49.269)",
      ring: "oklch(0.706 0.019 49.269)",
    },
    dark: {
      background: "oklch(0.146 0.01 49.25)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.21 0.014 49.269)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.21 0.014 49.269)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.926 0.01 49.269)",
      "primary-foreground": "oklch(0.21 0.014 49.269)",
      secondary: "oklch(0.271 0.012 40.998)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.271 0.012 40.998)",
      "muted-foreground": "oklch(0.706 0.019 49.269)",
      accent: "oklch(0.271 0.012 40.998)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.554 0.015 49.269)",
    },
  },
}

const withSidebarTokens = (mode, tokens) => ({
  ...tokens,
  sidebar: tokens.background ?? (mode === "dark" ? "oklch(0.145 0 0)" : "oklch(1 0 0)"),
  "sidebar-foreground": tokens.foreground,
  "sidebar-primary": tokens.primary,
  "sidebar-primary-foreground": tokens["primary-foreground"],
  "sidebar-accent": tokens.secondary ?? tokens.accent,
  "sidebar-accent-foreground":
    tokens["secondary-foreground"] ?? tokens["accent-foreground"],
  "sidebar-border": tokens.border,
  "sidebar-ring": tokens.ring,
})

Object.values(themePresets).forEach((palette) => {
  Object.entries(palette).forEach(([mode, tokens]) => {
    palette[mode] = withSidebarTokens(mode, tokens)
  })
})

const radiusPresets = {
  maia: "0.375rem",
  mira: "0.5rem",
  nova: "0.75rem",
  lyra: "0.875rem",
  vega: "1rem",
}

// Build the complete set of CSS custom property names so we can clear stale
// tokens when switching palettes.
const themedTokenKeys = Array.from(
  new Set(
    Object.values(themePresets).flatMap((palette) =>
      Object.values(palette).flatMap((modeTokens) => Object.keys(modeTokens))
    )
  )
)

const media = window.matchMedia("(prefers-color-scheme: dark)")
const root = document.documentElement
const docsSidebarRoot = document.querySelector("[data-docs-sidebar]")
const sidebar =
  docsSidebarRoot?.querySelector("[data-slot='sidebar-content']") || docsSidebarRoot
const colorSelectRoot = document.querySelector("#theme-color[data-slot='select']")
const radiusSelectRoot = document.querySelector("#theme-radius[data-slot='select']")
const colorSelect = colorSelectRoot?.querySelector("[data-slot='select-input']")
const radiusSelect = radiusSelectRoot?.querySelector("[data-slot='select-input']")
const themeModeButtons = () => qs(document, ".theme-mode-btn[data-theme-mode]")

const readSetting = (key, fallback) => localStorage.getItem(key) || fallback
const writeSetting = (key, value) => localStorage.setItem(key, value)
const resolveMode = (mode) => (mode === "auto" ? (media.matches ? "dark" : "light") : mode)
const normalizeMode = (mode) => (["light", "dark", "auto"].includes(mode) ? mode : "auto")
const normalizeColor = (color) => (themePresets[color] ? color : "neutral")
const normalizeRadius = (radius) => (radiusPresets[radius] ? radius : "nova")

/** Write the palette's CSS custom properties onto :root. */
const applyPalette = (color, resolvedMode) => {
  const palette = themePresets[color] || themePresets.neutral
  const tokens = palette[resolvedMode]
  themedTokenKeys.forEach((token) => {
    root.style.removeProperty(`--${token}`)
  })
  Object.entries(tokens).forEach(([token, value]) => {
    root.style.setProperty(`--${token}`, value)
  })
}

/** Keep the custom select UI in sync with the hidden input value. */
const syncSelectControl = (selectRoot, value) => {
  if (!selectRoot) return

  const input = selectRoot.querySelector("[data-slot='select-input']")
  const valueEl = selectRoot.querySelector("[data-slot='select-value']")
  const items = qs(selectRoot, "[data-select-item]")
  const selectedItem = items.find((item) => item.dataset.value === value) || null
  const placeholder = selectRoot.dataset.placeholder || ""

  if (input) input.value = selectedItem?.dataset.value || ""
  if (valueEl) valueEl.textContent = selectedItem?.dataset.label || selectedItem?.textContent?.trim() || placeholder

  const trigger = selectRoot.querySelector("[data-select-trigger]")
  if (trigger) {
    trigger.classList.toggle("text-muted-foreground", !selectedItem)
  }

  items.forEach((item) => {
    const selected = item === selectedItem
    item.dataset.selected = selected ? "true" : "false"
    item.setAttribute("aria-selected", selected ? "true" : "false")
    const check = item.querySelector("[data-slot='select-check']")
    if (check) check.classList.toggle("hidden", !selected)
  })
}

/** Keep the theme picker controls in sync with the current settings. */
const syncThemeControls = (mode, color, radius) => {
  themeModeButtons().forEach((button) => {
    const active = button.dataset.themeMode === mode
    button.dataset.active = active ? "true" : "false"
    button.dataset.state = active ? "active" : "inactive"
    button.setAttribute("aria-pressed", active ? "true" : "false")
    button.setAttribute("aria-selected", active ? "true" : "false")
  })

  syncSelectControl(colorSelectRoot, color)
  syncSelectControl(radiusSelectRoot, radius)
}

/** Read settings from localStorage and apply them to the document. */
const applyTheme = () => {
  const mode = normalizeMode(readSetting(themeStorage.mode, "auto"))
  const color = normalizeColor(readSetting(themeStorage.color, "neutral"))
  const radius = normalizeRadius(readSetting(themeStorage.radius, "nova"))
  const resolvedMode = resolveMode(mode)
  root.classList.toggle("dark", resolvedMode === "dark")
  root.dataset.theme = resolvedMode
  root.dataset.themeMode = mode
  root.dataset.themeColor = color
  root.dataset.themeRadius = radius
  applyPalette(color, resolvedMode)
  root.style.setProperty("--radius", radiusPresets[radius] || radiusPresets.nova)
  syncThemeControls(mode, color, radius)
}

// Bind theme picker controls.
document.addEventListener("click", (event) => {
  const button = event.target.closest(".theme-mode-btn[data-theme-mode]")
  if (!button) return

  writeSetting(themeStorage.mode, button.dataset.themeMode || "auto")
  applyTheme()
})

colorSelect?.addEventListener("change", () => {
  writeSetting(themeStorage.color, colorSelect.value)
  applyTheme()
})

radiusSelect?.addEventListener("change", () => {
  writeSetting(themeStorage.radius, radiusSelect.value)
  applyTheme()
})

// Re-apply when system preference changes while "auto" is selected.
if (typeof media.addEventListener === "function") {
  media.addEventListener("change", () => {
    if (readSetting(themeStorage.mode, "auto") === "auto") applyTheme()
  })
}

applyTheme()

// ---------------------------------------------------------------------------
// Sidebar scroll persistence — remember and restore the sidebar scroll
// position across page navigations so users don't lose their place.
// ---------------------------------------------------------------------------

const sidebarScrollStorageKey = "cui:docs:sidebar-scroll-top"

const restoreSidebarScroll = () => {
  if (!sidebar) return
  try {
    const saved = Number.parseInt(sessionStorage.getItem(sidebarScrollStorageKey) || "", 10)
    if (!Number.isFinite(saved) || saved < 0) return
    requestAnimationFrame(() => {
      sidebar.scrollTop = saved
    })
  } catch (_error) {
    // sessionStorage may be blocked in some contexts.
  }
}

const persistSidebarScroll = () => {
  if (!sidebar) return
  try {
    sessionStorage.setItem(sidebarScrollStorageKey, String(sidebar.scrollTop))
  } catch (_error) {
    // no-op
  }
}

restoreSidebarScroll()

sidebar?.addEventListener("scroll", persistSidebarScroll, { passive: true })
qs(sidebar || document, "a[href]").forEach((link) => {
  link.addEventListener("click", persistSidebarScroll)
})
window.addEventListener("beforeunload", persistSidebarScroll)

// ---------------------------------------------------------------------------
// Command palette (Cmd/Ctrl+K) — builds a searchable list of component links
// from the sidebar navigation and presents them in a modal overlay.
// ---------------------------------------------------------------------------

const initCommandPalette = () => {
  const navLinks = qs(
    document,
    "nav[aria-label='Component sections'] [data-slot='sidebar-item-link'][href], [data-command-palette-item][href]",
  )
  const items = []
  const seen = new Set()

  const moduleNameForLink = (link) => {
    const sectionItem = link
      .closest("[data-slot='sidebar-item-children']")
      ?.closest("[data-slot='sidebar-item']")

    if (!sectionItem) return ""

    const sectionButtonLabel = sectionItem.querySelector(
      "[data-slot='sidebar-item-button'] [data-sidebar-label]",
    )

    return (sectionButtonLabel?.textContent || "").trim()
  }

  const groupNameForLink = (link) => {
    const group = link.closest("[data-slot='sidebar-group']")
    if (!group) return ""

    const groupLabel = group.querySelector(":scope > div:first-child > [data-sidebar-label]")

    const label = (groupLabel?.textContent || "").trim()
    if (label === "Components") return "Component"
    return label
  }

  navLinks.forEach((link) => {
    const hrefAttr = link.getAttribute("href")
    if (!hrefAttr) return

    const href = new URL(hrefAttr, window.location.href).toString()
    if (seen.has(href)) return
    seen.add(href)

    const moduleName = link.dataset.commandPaletteModule || moduleNameForLink(link)
    const groupName = link.dataset.commandPaletteGroup || groupNameForLink(link)
    const title = link.dataset.commandPaletteTitle || (link.textContent || "").trim()
    if (!title) return

    const displayName = moduleName ? `${moduleName}.${title}` : title

    items.push({
      title,
      moduleName,
      groupName,
      displayName,
      queryText: `${displayName} ${title} ${moduleName} ${groupName}`.toLowerCase(),
      href,
    })
  })

  if (!items.length) return

  const openButtons = qs(document, "[data-open-command-palette]")

  const shell = document.createElement("div")
  shell.className = "docs-k hidden"
  shell.innerHTML = `
    <div class="docs-k-backdrop" data-k-close></div>
    <div class="docs-k-panel" role="dialog" aria-modal="true" aria-label="Jump to component">
      <div class="docs-k-input-row">
        <input type="text" class="docs-k-input" placeholder="Jump to component..." />
      </div>
      <ul class="docs-k-list"></ul>
    </div>
  `
  document.body.appendChild(shell)

  const input = shell.querySelector(".docs-k-input")
  const list = shell.querySelector(".docs-k-list")
  let filtered = items.slice()
  let activeIndex = 0

  const syncOpenButtons = (open) => {
    openButtons.forEach((button) => {
      button.dataset.state = open ? "active" : "inactive"
      button.setAttribute("aria-expanded", open ? "true" : "false")
    })
  }

  const close = () => {
    shell.classList.add("hidden")
    document.body.style.removeProperty("overflow")
    syncOpenButtons(false)
  }

  const open = () => {
    shell.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    input.value = ""
    activeIndex = 0
    render()
    syncOpenButtons(true)
    requestAnimationFrame(() => input.focus())
  }

  openButtons.forEach((button) => {
    button.addEventListener("click", () => open())
  })

  const navigate = (item) => {
    if (!item) return
    window.location.assign(item.href)
  }

  const render = () => {
    const query = (input.value || "").trim().toLowerCase()
    filtered = query
      ? items.filter((item) => item.queryText.includes(query))
      : items.slice()

    const visibleCount = Math.min(filtered.length, 24)
    if (activeIndex >= visibleCount) activeIndex = 0

    if (!filtered.length) {
      list.innerHTML = `<li class="docs-k-empty">No components found.</li>`
      return
    }

    list.innerHTML = filtered
      .slice(0, 24)
      .map((item, index) => {
        const active = index === activeIndex ? "true" : "false"
        const label = escapeHtml(item.displayName)
        const meta = item.groupName ? escapeHtml(item.groupName) : "Component"
        return `<li><button type="button" class="docs-k-item" data-index="${index}" data-active="${active}"><span class="docs-k-item-label">${label}</span><span class="docs-k-item-meta">${meta}</span></button></li>`
      })
      .join("")

    const activeButton = list.querySelector(`.docs-k-item[data-index="${activeIndex}"]`)
    activeButton?.scrollIntoView({ block: "nearest" })
  }

  shell.addEventListener("click", (event) => {
    if (event.target.closest("[data-k-close]")) {
      close()
      return
    }

    const item = event.target.closest(".docs-k-item")
    if (!item) return
    const index = Number.parseInt(item.dataset.index || "0", 10)
    navigate(filtered[index])
  })

  input.addEventListener("input", () => {
    activeIndex = 0
    render()
  })

  input.addEventListener("keydown", (event) => {
    const visibleCount = Math.min(filtered.length, 24)

    if (event.key === "ArrowDown") {
      event.preventDefault()
      if (!visibleCount) return
      activeIndex = (activeIndex + 1) % visibleCount
      render()
      return
    }

    if (event.key === "ArrowUp") {
      event.preventDefault()
      if (!visibleCount) return
      activeIndex = (activeIndex - 1 + visibleCount) % visibleCount
      render()
      return
    }

    if (event.key === "Enter") {
      event.preventDefault()
      navigate(filtered[activeIndex])
      return
    }

    if (event.key === "Escape") {
      event.preventDefault()
      close()
    }
  })

  document.addEventListener("keydown", (event) => {
    const wantsPalette = (event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k"
    if (wantsPalette) {
      event.preventDefault()
      if (shell.classList.contains("hidden")) open()
      else close()
      return
    }

    if (event.key === "Escape" && !shell.classList.contains("hidden")) {
      event.preventDefault()
      close()
    }
  })
}

initCommandPalette()

// ---------------------------------------------------------------------------
// Copy-to-clipboard buttons — each button has a data-copy-template attribute
// that references a <code id="code-{id}"> element containing the HEEx snippet.
// ---------------------------------------------------------------------------

qs(document, "[data-copy-template]").forEach((button) => {
  button.addEventListener("click", async () => {
    const id = button.getAttribute("data-copy-template")
    const code = document.getElementById(`code-${id}`)
    if (!code) return

    const text = code.textContent || ""
    try {
      await navigator.clipboard.writeText(text)
      const original = button.innerHTML
      button.innerHTML = "✓"
      setTimeout(() => {
        button.innerHTML = original
      }, 1200)
    } catch (_error) {
      // Clipboard API may be unavailable (e.g. non-HTTPS).
    }
  })
})

if (shouldAutoInitializeStaticDocs) {
  initializeStaticHooks()
}

// ---------------------------------------------------------------------------
// Tabs previews — switch active trigger/panel state in static docs examples.
// ---------------------------------------------------------------------------

const syncTabsPreview = (root, nextTrigger) => {
  const triggers = qs(root, "[data-slot='tabs-trigger']")
  const panels = qs(root, "[data-slot='tabs-content']")
  const controls = nextTrigger.getAttribute("aria-controls")

  triggers.forEach((trigger) => {
    const active = trigger === nextTrigger
    trigger.dataset.state = active ? "active" : "inactive"
    trigger.setAttribute("aria-selected", active ? "true" : "false")
    trigger.tabIndex = active ? 0 : -1
  })

  panels.forEach((panel) => {
    const active = panel.id === controls
    panel.dataset.state = active ? "active" : "inactive"
    panel.classList.toggle("hidden", !active)
  })
}

qs(document, "[data-slot='tabs']").forEach((root) => {
  const triggers = qs(root, "[data-slot='tabs-trigger']")
  const panels = qs(root, "[data-slot='tabs-content']")

  if (triggers.length === 0 || panels.length === 0) return

  syncTabsPreview(root, triggers.find((trigger) => trigger.getAttribute("aria-selected") === "true") || triggers[0])
})

document.addEventListener("click", (event) => {
  const trigger = event.target instanceof Element ? event.target.closest("[data-slot='tabs-trigger']") : null
  if (!trigger) return

  const root = trigger.closest("[data-slot='tabs']")
  if (!root) return

  const panels = qs(root, "[data-slot='tabs-content']")
  if (panels.length === 0) return

  syncTabsPreview(root, trigger)
})
