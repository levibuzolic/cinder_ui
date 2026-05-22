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

const themeRuntime = globalThis.CinderUITheme
const docsSidebarRoot = document.querySelector("[data-docs-sidebar]")
const sidebar =
  docsSidebarRoot?.querySelector("[data-slot='sidebar-content']") || docsSidebarRoot
const colorSelectRoot = document.querySelector("#theme-color[data-slot='select']")
const radiusSelectRoot = document.querySelector("#theme-radius[data-slot='select']")
const colorSelect = colorSelectRoot?.querySelector("[data-slot='select-input']")
const radiusSelect = radiusSelectRoot?.querySelector("[data-slot='select-input']")

// Bind theme picker controls.
document.addEventListener("click", (event) => {
  const button = event.target.closest(".theme-mode-btn[data-theme-mode]")
  if (!button || !themeRuntime) return

  themeRuntime.setThemeSetting("mode", button.dataset.themeMode || themeRuntime.defaults.mode)
})

colorSelect?.addEventListener("change", () => {
  themeRuntime?.setThemeSetting("color", colorSelect.value)
})

radiusSelect?.addEventListener("change", () => {
  themeRuntime?.setThemeSetting("radius", radiusSelect.value)
})

themeRuntime?.watchSystemTheme()
themeRuntime?.watchThemeStorage()
themeRuntime?.applyStoredTheme()

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
