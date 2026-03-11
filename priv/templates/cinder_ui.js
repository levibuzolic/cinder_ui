// -----------------------------------------------------------------------------
// MARK: Constants
// -----------------------------------------------------------------------------

/** Custom event name used for imperative component commands. */
const COMMAND_EVENT = "cinder-ui:command"

/** Selector matching all natively focusable, non-disabled elements. */
const FOCUSABLE_SELECTOR =
  "button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])"

// -----------------------------------------------------------------------------
// MARK: Utilities
// -----------------------------------------------------------------------------

/**
 * Toggle an element's visibility by adding/removing the `hidden` class and
 * setting `data-state` to `"open"` or `"closed"`.
 * @param {HTMLElement | null} el
 * @param {boolean} visible
 */
const toggleVisibility = (el, visible) => {
  if (!el) return
  if (visible) {
    el.classList.remove("hidden")
    el.dataset.state = "open"
  } else {
    el.classList.add("hidden")
    el.dataset.state = "closed"
  }
}

/**
 * Walk up from `target` to find the nearest ancestor matching `selector`.
 * Returns the matched element or `null`.
 * @param {EventTarget | null} target
 * @param {string} selector
 * @returns {HTMLElement | null}
 */
const clickClosest = (target, selector) => target && target.closest(selector)

/**
 * Clamp `value` between `min` and `max` (inclusive).
 * @param {number} value
 * @param {number} min
 * @param {number} max
 * @returns {number}
 */
const clamp = (value, min, max) => Math.min(Math.max(value, min), max)

/**
 * Parse a string as a percentage number, returning `fallback` when the value
 * is empty or not a finite number.
 * @param {string | null | undefined} value
 * @param {number} fallback
 * @returns {number}
 */
const parsePercentage = (value, fallback) => {
  if (value === null || value === undefined || value === "") return fallback
  const parsed = Number.parseFloat(value)
  return Number.isFinite(parsed) ? parsed : fallback
}

/**
 * Normalize an array of percentage values so they sum to 100.
 * If the total is zero or negative, distributes equally.
 * @param {number[]} values
 * @returns {number[]}
 */
const normalizePercentages = (values) => {
  if (!values.length) return values
  const total = values.reduce((sum, value) => sum + value, 0)
  if (total <= 0) return values.map(() => 100 / values.length)
  return values.map((value) => (value / total) * 100)
}

/**
 * Create highlight helpers for a listbox-style component.
 *
 * Returns an object with:
 * - `highlight(target)` — mark a single item (or `null` to clear all)
 * - `onMouseEnter` / `onMouseLeave` / `onFocus` — event handlers
 * - `bind(items)` / `unbind(items)` — attach/detach listeners on item elements
 *
 * @param {() => HTMLElement[]} getItems - Returns current item elements.
 * @param {() => void} [onAfterHighlight] - Optional callback after highlight changes (e.g. sync ARIA).
 */
const createItemHighlighter = (getItems, onAfterHighlight) => {
  const highlight = (target) => {
    for (const item of getItems()) {
      item.dataset.highlighted = item === target ? "true" : "false"
    }
    if (onAfterHighlight) onAfterHighlight()
  }

  const onFocus = (event) => highlight(event.currentTarget)
  const onMouseEnter = (event) => highlight(event.currentTarget)
  const onMouseLeave = () => highlight(null)

  const bind = (items) => {
    for (const item of items) {
      item.addEventListener("focus", onFocus)
      item.addEventListener("mouseenter", onMouseEnter)
      item.addEventListener("mouseleave", onMouseLeave)
    }
  }

  const unbind = (items) => {
    for (const item of items) {
      item.removeEventListener("focus", onFocus)
      item.removeEventListener("mouseenter", onMouseEnter)
      item.removeEventListener("mouseleave", onMouseLeave)
    }
  }

  return { highlight, onFocus, onMouseEnter, onMouseLeave, bind, unbind }
}

/**
 * Create a simple typeahead matcher for menu/listbox items.
 *
 * Repeated printable keys within a short window extend the current query.
 *
 * @param {() => HTMLElement[]} getItems
 * @param {(item: HTMLElement) => string} getLabel
 * @param {(item: HTMLElement) => void} onMatch
 */
const createTypeaheadMatcher = (getItems, getLabel, onMatch) => {
  let buffer = ""
  let resetTimer = null

  const reset = () => {
    buffer = ""
    if (resetTimer) window.clearTimeout(resetTimer)
    resetTimer = null
  }

  const search = (key) => {
    if (key.length !== 1) return false

    buffer = `${buffer}${key.toLowerCase()}`
    if (resetTimer) window.clearTimeout(resetTimer)
    resetTimer = window.setTimeout(reset, 500)

    const items = getItems()
    const match =
      items.find((item) => getLabel(item).toLowerCase().startsWith(buffer)) ||
      items.find((item) => getLabel(item).toLowerCase().startsWith(key.toLowerCase()))

    if (!match) return false
    onMatch(match)
    return true
  }

  return { search, reset }
}

// -----------------------------------------------------------------------------
// MARK: Command System
// -----------------------------------------------------------------------------

/**
 * Register a listener for {@link COMMAND_EVENT} on `root`.
 *
 * Commands are dispatched as `CustomEvent` instances whose `detail.command`
 * string is looked up in the `handlers` map.
 *
 * @param {HTMLElement} root - Element to listen on (events do not bubble).
 * @param {Record<string, (detail: object) => void>} handlers
 * @returns {() => void} Cleanup function that removes the listener.
 */
const registerCommandListener = (root, handlers) => {
  const onCommand = (event) => {
    const command = event.detail?.command
    if (!command) return

    const handler = handlers[command]
    if (typeof handler === "function") {
      handler(event.detail || {})
    }
  }

  root.addEventListener(COMMAND_EVENT, onCommand)
  return () => root.removeEventListener(COMMAND_EVENT, onCommand)
}

/**
 * Dispatch a command to a component's root element.
 *
 * @example
 * ```js
 * CinderUI.dispatchCommand(selectEl, "open")
 * CinderUI.dispatchCommand(dialogEl, "close")
 * ```
 *
 * @param {HTMLElement | null} target
 * @param {string} command
 * @param {object} [detail={}]
 */
const dispatchCommand = (target, command, detail = {}) => {
  if (!target) return
  target.dispatchEvent(
    new CustomEvent(COMMAND_EVENT, {
      bubbles: false,
      detail: { ...detail, command },
    }),
  )
}

// -----------------------------------------------------------------------------
// MARK: Focus Management
// -----------------------------------------------------------------------------

/**
 * Return all focusable, visible elements inside `root`.
 * @param {HTMLElement | null} root
 * @returns {HTMLElement[]}
 */
const getFocusableElements = (root) =>
  root ? Array.from(root.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) => !el.hasAttribute("hidden")) : []

/**
 * Focus the first focusable element inside `root`. Falls back to focusing
 * `root` itself if no focusable children exist.
 * @param {HTMLElement | null} root
 * @returns {boolean} Whether an element was focused.
 */
const focusFirst = (root) => {
  const first = getFocusableElements(root)[0]
  if (first) {
    first.focus()
    return true
  }

  if (root && typeof root.focus === "function") {
    root.focus()
    return true
  }

  return false
}

/**
 * Return the first focusable element inside `root`, or `root` itself.
 * @param {HTMLElement | null} root
 * @returns {HTMLElement | null}
 */
const getFocusTarget = (root) => getFocusableElements(root)[0] || root || null

/**
 * Restore focus to `preferred` if it is still in the DOM, otherwise fall back
 * to `fallback`.
 * @param {HTMLElement | null} preferred
 * @param {HTMLElement | null} fallback
 */
const restoreFocus = (preferred, fallback) => {
  if (preferred && document.contains(preferred) && typeof preferred.focus === "function") {
    preferred.focus()
    return
  }

  if (fallback && document.contains(fallback) && typeof fallback.focus === "function") {
    fallback.focus()
  }
}

// -----------------------------------------------------------------------------
// MARK: Inert Management
// -----------------------------------------------------------------------------

/**
 * Apply the `inert` attribute to all sibling branches of `overlayEl` up to
 * `document.body`, effectively trapping interaction inside the overlay.
 *
 * @param {HTMLElement} overlayEl
 * @returns {HTMLElement[]} Elements that were marked inert (for later cleanup).
 */
const applyInert = (overlayEl) => {
  const inertedElements = []
  let current = overlayEl

  while (current && current !== document.body) {
    const parent = current.parentElement
    if (parent) {
      for (const sibling of parent.children) {
        if (sibling !== current && !sibling.inert) {
          sibling.inert = true
          inertedElements.push(sibling)
        }
      }
    }
    current = parent
  }

  return inertedElements
}

/**
 * Remove the `inert` attribute from elements previously marked by
 * {@link applyInert}.
 * @param {HTMLElement[] | null} inertedElements
 */
const removeInert = (inertedElements) => {
  if (!inertedElements) return
  for (const el of inertedElements) {
    el.inert = false
  }
}

// -----------------------------------------------------------------------------
// MARK: Dialog
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `dialog` component.
 *
 * Manages open/close state, focus trapping via `inert`, and focus restoration.
 *
 * **Data attributes:** `data-dialog-trigger`, `data-dialog-overlay`,
 * `data-dialog-content`, `data-dialog-close`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiDialog = {
  mounted() {
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-dialog-trigger]")
      this.content = this.el.querySelector("[data-dialog-content]")
    }

    this.refreshElements()
    this.lastActiveElement = null
    this.inertedElements = null
    this.sync(this.el.dataset.state === "open")

    this.handleEvent = (event) => {
      if (clickClosest(event.target, "[data-dialog-trigger]")) {
        this.lastActiveElement = getFocusTarget(this.trigger)
        this.sync(true)
      }
      if (clickClosest(event.target, "[data-dialog-close]") || clickClosest(event.target, "[data-dialog-overlay]")) this.sync(false)
    }

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.el.dataset.state === "open") {
        event.preventDefault()
        this.sync(false)
      }
    }

    this.el.addEventListener("click", this.handleEvent)
    document.addEventListener("keydown", this.onKeydown)
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => this.sync(true),
      close: () => this.sync(false),
      toggle: () => this.sync(this.el.dataset.state !== "open"),
      focus: () => this.trigger?.focus(),
    })
  },

  updated() {
    this.refreshElements()
    this.sync(this.el.dataset.state === "open")
  },

  /** @param {boolean} open */
  sync(open) {
    const wasOpen = this.el.dataset.state === "open"

    if (open && !wasOpen) {
      this.lastActiveElement =
        this.lastActiveElement ||
        (document.activeElement instanceof HTMLElement ? document.activeElement : getFocusTarget(this.trigger))
    }

    this.el.dataset.state = open ? "open" : "closed"
    toggleVisibility(this.el.querySelector("[data-dialog-overlay]"), open)
    toggleVisibility(this.content, open)

    if (open && !wasOpen) {
      this.inertedElements = applyInert(this.el)
    }

    if (!open && wasOpen) {
      removeInert(this.inertedElements)
      this.inertedElements = null
    }

    if (open && !wasOpen) {
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    removeInert(this.inertedElements)
    this.el.removeEventListener("click", this.handleEvent)
    document.removeEventListener("keydown", this.onKeydown)
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Panel (Drawer & Sheet)
// -----------------------------------------------------------------------------

/**
 * Factory that creates a LiveView hook for overlay panel components (drawer,
 * sheet). Panels share identical open/close, focus-trap, and inert logic —
 * only the data-attribute selectors differ.
 *
 * @param {object} config
 * @param {string} config.triggerSelector
 * @param {string} config.overlaySelector
 * @param {string} config.contentSelector
 * @returns {import("phoenix_live_view").ViewHookInterface}
 */
const createPanelHook = (config) => ({
  mounted() {
    this.refreshElements = () => {
      this.trigger = this.el.querySelector(config.triggerSelector)
      this.content = this.el.querySelector(config.contentSelector)
    }

    this.refreshElements()
    this.lastActiveElement = null
    this.inertedElements = null
    this.sync(this.el.dataset.state === "open")

    this.handleEvent = (event) => {
      if (clickClosest(event.target, config.triggerSelector)) {
        this.lastActiveElement = getFocusTarget(this.trigger)
        this.sync(true)
      }
      if (clickClosest(event.target, config.overlaySelector)) this.sync(false)
    }

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.el.dataset.state === "open") {
        event.preventDefault()
        this.sync(false)
      }
    }

    this.el.addEventListener("click", this.handleEvent)
    document.addEventListener("keydown", this.onKeydown)
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => this.sync(true),
      close: () => this.sync(false),
      toggle: () => this.sync(this.el.dataset.state !== "open"),
      focus: () => this.trigger?.focus(),
    })
  },

  updated() {
    this.refreshElements()
    this.sync(this.el.dataset.state === "open")
  },

  /** @param {boolean} open */
  sync(open) {
    const wasOpen = this.el.dataset.state === "open"

    if (open && !wasOpen) {
      this.lastActiveElement =
        this.lastActiveElement ||
        (document.activeElement instanceof HTMLElement ? document.activeElement : getFocusTarget(this.trigger))
    }

    this.el.dataset.state = open ? "open" : "closed"
    toggleVisibility(this.el.querySelector(config.overlaySelector), open)
    toggleVisibility(this.content, open)

    if (open && !wasOpen) {
      this.inertedElements = applyInert(this.el)
    }

    if (!open && wasOpen) {
      removeInert(this.inertedElements)
      this.inertedElements = null
    }

    if (open && !wasOpen) {
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    removeInert(this.inertedElements)
    this.el.removeEventListener("click", this.handleEvent)
    document.removeEventListener("keydown", this.onKeydown)
    this.removeCommandListener && this.removeCommandListener()
  },
})

/**
 * Phoenix LiveView hook for the `drawer` component.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiDrawer = createPanelHook({
  triggerSelector: "[data-drawer-trigger]",
  overlaySelector: "[data-drawer-overlay]",
  contentSelector: "[data-drawer-content]",
})

/**
 * Phoenix LiveView hook for the `sheet` component.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiSheet = createPanelHook({
  triggerSelector: "[data-sheet-trigger]",
  overlaySelector: "[data-sheet-overlay]",
  contentSelector: "[data-sheet-content]",
})

// -----------------------------------------------------------------------------
// MARK: Popover
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `popover` component.
 *
 * Toggles a floating content panel anchored to a trigger button. Closes on
 * outside click or Escape.
 *
 * **Data attributes:** `data-popover-trigger`, `data-popover-content`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiPopover = {
  mounted() {
    this.open = false
    this.lastActiveElement = null
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-popover-trigger]")
      this.content = this.el.querySelector("[data-popover-content]")
    }

    this.toggle = () => {
      if (!this.open) this.lastActiveElement = getFocusTarget(this.trigger)
      this.sync(!this.open)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        this.sync(false)
      }
    }

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.open) {
        event.preventDefault()
        this.sync(false)
      }
    }

    this.bindEvents = () => {
      this.trigger && this.trigger.addEventListener("click", this.toggle)
      document.addEventListener("click", this.onDocumentClick)
      document.addEventListener("keydown", this.onKeydown)
    }

    this.unbindEvents = () => {
      this.trigger && this.trigger.removeEventListener("click", this.toggle)
      document.removeEventListener("click", this.onDocumentClick)
      document.removeEventListener("keydown", this.onKeydown)
    }

    this.refreshElements()
    this.bindEvents()
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => this.sync(true),
      close: () => this.sync(false),
      toggle: () => this.toggle(),
      focus: () => this.trigger?.focus(),
    })
  },

  updated() {
    this.unbindEvents()
    this.refreshElements()
    this.bindEvents()
    this.sync(this.open)
  },

  /** @param {boolean} open */
  sync(open) {
    const wasOpen = this.open

    if (open && !wasOpen) {
      this.lastActiveElement =
        this.lastActiveElement ||
        (document.activeElement instanceof HTMLElement ? document.activeElement : getFocusTarget(this.trigger))
    }

    this.open = open
    toggleVisibility(this.content, open)
    if (this.trigger) this.trigger.setAttribute("aria-expanded", open ? "true" : "false")

    if (open && !wasOpen) {
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Dropdown Menu
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `dropdown_menu` component.
 *
 * Behaviour is identical to {@link CuiPopover} but uses dropdown-specific
 * data attributes.
 *
 * **Data attributes:** `data-dropdown-trigger`, `data-dropdown-content`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiDropdownMenu = {
  mounted() {
    this.open = false
    this.lastActiveElement = null
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-dropdown-trigger]")
      this.content = this.el.querySelector("[data-dropdown-content]")
      this.items = Array.from(this.el.querySelectorAll("[data-slot='dropdown-menu-item']")).filter(
        (item) => !item.disabled,
      )
    }

    this.typeahead = createTypeaheadMatcher(
      () => this.items || [],
      (item) => item.textContent || "",
      (item) => item.focus(),
    )

    this.toggle = () => {
      if (!this.open) this.lastActiveElement = getFocusTarget(this.trigger)
      this.sync(!this.open)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        this.sync(false)
      }
    }

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.open) {
        event.preventDefault()
        this.sync(false)
      }

      if (this.open && this.typeahead.search(event.key)) {
        event.preventDefault()
      }
    }

    this.bindEvents = () => {
      this.trigger && this.trigger.addEventListener("click", this.toggle)
      document.addEventListener("click", this.onDocumentClick)
      document.addEventListener("keydown", this.onKeydown)
    }

    this.unbindEvents = () => {
      this.trigger && this.trigger.removeEventListener("click", this.toggle)
      document.removeEventListener("click", this.onDocumentClick)
      document.removeEventListener("keydown", this.onKeydown)
    }

    this.refreshElements()
    this.bindEvents()
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => this.sync(true),
      close: () => this.sync(false),
      toggle: () => this.toggle(),
      focus: () => this.trigger?.focus(),
    })
  },

  updated() {
    this.unbindEvents()
    this.refreshElements()
    this.bindEvents()
    this.sync(this.open)
  },

  /** @param {boolean} open */
  sync(open) {
    const wasOpen = this.open

    if (open && !wasOpen) {
      this.lastActiveElement =
        this.lastActiveElement ||
        (document.activeElement instanceof HTMLElement ? document.activeElement : getFocusTarget(this.trigger))
    }

    this.open = open
    toggleVisibility(this.content, open)
    if (this.trigger) this.trigger.setAttribute("aria-expanded", open ? "true" : "false")

    if (open && !wasOpen) {
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    this.typeahead.reset()
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Menubar
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `menubar` component.
 *
 * Supports click-to-open menus, left/right trigger navigation, ArrowDown to
 * enter menu content, and Escape to close the active menu.
 *
 * **Data attributes:** `data-menubar-trigger`, `data-menubar-content`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiMenubar = {
  mounted() {
    this.openIndex = -1
    this.refreshElements = () => {
      this.menus = Array.from(this.el.querySelectorAll("[data-slot='menubar-menu']")).map((menu) => ({
        menu,
        trigger: menu.querySelector("[data-menubar-trigger]"),
        content: menu.querySelector("[data-menubar-content]"),
      }))
    }

    this.sync = () => {
      this.menus.forEach(({ trigger, content }, index) => {
        const open = index === this.openIndex
        toggleVisibility(content, open)
        if (trigger) trigger.setAttribute("aria-expanded", open ? "true" : "false")
      })
    }

    this.focusTrigger = (index) => {
      const normalized = (index + this.menus.length) % this.menus.length
      this.menus[normalized]?.trigger?.focus()
      return normalized
    }

    this.openMenu = (index, focusContent = false) => {
      this.openIndex = index
      this.sync()
      if (focusContent) {
        window.requestAnimationFrame(() => focusFirst(this.menus[index]?.content))
      }
    }

    this.closeMenu = () => {
      const activeIndex = this.openIndex
      this.openIndex = -1
      this.sync()
      if (activeIndex >= 0) {
        this.menus[activeIndex]?.trigger?.focus()
      }
    }

    this.onClick = (event) => {
      const trigger = clickClosest(event.target, "[data-menubar-trigger]")
      if (trigger) {
        const index = this.menus.findIndex((menu) => menu.trigger === trigger)
        if (index >= 0) {
          if (this.openIndex === index) {
            this.closeMenu()
          } else {
            this.openMenu(index)
          }
        }
        return
      }

      if (!this.el.contains(event.target)) {
        this.openIndex = -1
        this.sync()
      }
    }

    this.onKeydown = (event) => {
      const triggerIndex = this.menus.findIndex(({ trigger }) => trigger === event.target)
      const contentIndex = this.menus.findIndex(
        ({ content }) => content && content.contains(event.target),
      )
      const activeIndex = triggerIndex >= 0 ? triggerIndex : contentIndex

      if (activeIndex < 0) return

      if (event.key === "ArrowRight") {
        event.preventDefault()
        const nextIndex = this.focusTrigger(activeIndex + 1)
        if (this.openIndex >= 0) this.openMenu(nextIndex)
      }

      if (event.key === "ArrowLeft") {
        event.preventDefault()
        const nextIndex = this.focusTrigger(activeIndex - 1)
        if (this.openIndex >= 0) this.openMenu(nextIndex)
      }

      if (event.key === "ArrowDown" && triggerIndex >= 0) {
        event.preventDefault()
        this.openMenu(triggerIndex, true)
      }

      if (event.key === "Escape" && this.openIndex >= 0) {
        event.preventDefault()
        this.closeMenu()
      }
    }

    this.refreshElements()
    this.sync()
    this.el.addEventListener("click", this.onClick)
    document.addEventListener("click", this.onClick)
    this.el.addEventListener("keydown", this.onKeydown)
  },

  updated() {
    this.refreshElements()
    if (this.openIndex >= this.menus.length) this.openIndex = -1
    this.sync()
  },

  destroyed() {
    this.el.removeEventListener("click", this.onClick)
    document.removeEventListener("click", this.onClick)
    this.el.removeEventListener("keydown", this.onKeydown)
  },
}

// -----------------------------------------------------------------------------
// MARK: Select
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the custom `select` component.
 *
 * Renders a button trigger with a listbox dropdown. Supports keyboard
 * navigation (Arrow keys, Home, End, Enter, Space, Escape), single selection,
 * and an optional clear button.
 *
 * **Data attributes:** `data-select-trigger`, `data-select-content`,
 * `data-select-item`, `data-select-clear`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`, `clear`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiSelect = {
  mounted() {
    this.open = false
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-select-trigger]")
      this.content = this.el.querySelector("[data-select-content]")
      this.input = this.el.querySelector("[data-slot='select-input']")
      this.clearButton = this.el.querySelector("[data-select-clear]")
      this.items = Array.from(this.el.querySelectorAll("[data-select-item]"))
    }

    /** @returns {HTMLElement[]} Enabled (non-disabled) option items. */
    this.enabledItems = () => this.items.filter((item) => item.dataset.disabled !== "true" && !item.disabled)

    /** @returns {number} Index of the currently selected item, or -1. */
    this.selectedIndex = () =>
      this.items.findIndex((item) => item.dataset.selected === "true")

    this._hl = createItemHighlighter(() => this.items, () => this.sync())
    this.highlightItem = this._hl.highlight
    this.typeahead = createTypeaheadMatcher(
      () => this.enabledItems(),
      (item) => item.dataset.label || item.textContent || "",
      (item) => {
        this.highlightItem(item)
        item.focus()
      },
    )

    /** Synchronize DOM state (visibility, ARIA attributes) with `this.open`. */
    this.sync = () => {
      this.el.dataset.state = this.open ? "open" : "closed"
      if (this.trigger) this.trigger.setAttribute("aria-expanded", this.open ? "true" : "false")
      const activeItem = this.items.find((item) => item.dataset.highlighted === "true")
      if (this.trigger) this.trigger.setAttribute("aria-activedescendant", this.open && activeItem ? activeItem.id : "")
      toggleVisibility(this.content, this.open)
    }

    /**
     * Focus an item by index within the enabled items list.
     * @param {number} index
     */
    this.focusItem = (index) => {
      const enabledItems = this.enabledItems()
      if (!enabledItems.length) return

      const nextIndex = Math.min(Math.max(index, 0), enabledItems.length - 1)
      this.highlightItem(enabledItems[nextIndex])
      enabledItems[nextIndex].focus()
    }

    /** Open the dropdown and focus the selected or first item. */
    this.openMenu = () => {
      if (this.open) return
      this.open = true
      this.sync()

      const enabledItems = this.enabledItems()
      if (!enabledItems.length) return

      const selectedIndex = this.selectedIndex()
      const selectedItem = selectedIndex >= 0 ? this.items[selectedIndex] : enabledItems[0]
      window.requestAnimationFrame(() => selectedItem && selectedItem.focus())
    }

    /** Close the dropdown. */
    this.closeMenu = () => {
      if (!this.open) return
      this.open = false
      this.sync()
    }

    /**
     * Commit a selection, update the hidden input, and close the menu.
     * @param {HTMLElement} item
     */
    this.selectItem = (item) => {
      const value = item.dataset.value || ""
      const label = item.dataset.label || item.textContent.trim()

      if (this.input) this.input.value = value
      this.items.forEach((entry) => {
        const selected = entry === item
        entry.dataset.selected = selected ? "true" : "false"
        entry.dataset.highlighted = "false"
        entry.setAttribute("aria-selected", selected ? "true" : "false")
        const check = entry.querySelector("[data-slot='select-check']")
        if (check) check.classList.toggle("hidden", !selected)
      })

      const valueEl = this.el.querySelector("[data-slot='select-value']")
      if (valueEl) valueEl.textContent = label
      if (this.clearButton) this.clearButton.classList.remove("hidden")

      this.closeMenu()
      if (this.trigger) this.trigger.focus()
      if (this.input) {
        this.input.dispatchEvent(new Event("input", { bubbles: true }))
        this.input.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }

    /** Reset to the placeholder and clear the hidden input value. */
    this.clearSelection = () => {
      const placeholder = this.el.dataset.placeholder || ""
      if (this.input) this.input.value = ""
      this.items.forEach((entry) => {
        entry.dataset.selected = "false"
        entry.dataset.highlighted = "false"
        entry.setAttribute("aria-selected", "false")
        const check = entry.querySelector("[data-slot='select-check']")
        if (check) check.classList.add("hidden")
      })

      const valueEl = this.el.querySelector("[data-slot='select-value']")
      if (valueEl) valueEl.textContent = placeholder
      if (this.clearButton) this.clearButton.classList.add("hidden")
      this.closeMenu()
      if (this.input) {
        this.input.dispatchEvent(new Event("input", { bubbles: true }))
        this.input.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }

    /**
     * Move focus by `delta` positions within the enabled items list.
     * @param {number} delta - +1 for next, -1 for previous.
     * @param {HTMLElement} current - Currently focused item.
     */
    this.move = (delta, current) => {
      const enabledItems = this.enabledItems()
      if (!enabledItems.length) return

      const currentIndex = enabledItems.indexOf(current)
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + enabledItems.length) % enabledItems.length
      enabledItems[nextIndex].focus()
    }

    // -- Event handlers -------------------------------------------------------

    this.onTriggerClick = () => {
      if (this.open) {
        this.closeMenu()
      } else {
        this.openMenu()
      }
    }

    this.onClearClick = (event) => {
      event.preventDefault()
      event.stopPropagation()
      this.clearSelection()
      this.trigger?.focus()
    }

    /** @param {KeyboardEvent} event */
    this.onTriggerKeyDown = (event) => {
      if (event.key === "ArrowDown" || event.key === "ArrowUp") {
        event.preventDefault()
        this.openMenu()
      }

      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault()
        if (this.open) {
          this.closeMenu()
        } else {
          this.openMenu()
        }
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.closeMenu()
      }

      if (this.typeahead.search(event.key)) {
        event.preventDefault()
        this.open = true
        this.sync()
      }
    }

    /** @param {KeyboardEvent} event */
    this.onContentKeyDown = (event) => {
      const current = event.target.closest("[data-select-item]")
      if (!current) return

      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.move(1, current)
      }

      if (event.key === "ArrowUp") {
        event.preventDefault()
        this.move(-1, current)
      }

      if (event.key === "Home") {
        event.preventDefault()
        this.focusItem(0)
      }

      if (event.key === "End") {
        event.preventDefault()
        this.focusItem(this.enabledItems().length - 1)
      }

      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault()
        this.selectItem(current)
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.closeMenu()
        if (this.trigger) this.trigger.focus()
      }

      if (this.typeahead.search(event.key)) {
        event.preventDefault()
      }
    }

    this.onItemClick = (event) => {
      const item = event.currentTarget
      if (item.dataset.disabled === "true" || item.disabled) return
      this.selectItem(item)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) this.closeMenu()
    }

    // -- Lifecycle ------------------------------------------------------------

    this.bindEvents = () => {
      this.trigger && this.trigger.addEventListener("click", this.onTriggerClick)
      this.clearButton && this.clearButton.addEventListener("click", this.onClearClick)
      this.trigger && this.trigger.addEventListener("keydown", this.onTriggerKeyDown)
      this.content && this.content.addEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
      this._hl.bind(this.items)
      document.addEventListener("click", this.onDocumentClick)
    }

    this.unbindEvents = () => {
      this.trigger && this.trigger.removeEventListener("click", this.onTriggerClick)
      this.clearButton && this.clearButton.removeEventListener("click", this.onClearClick)
      this.trigger && this.trigger.removeEventListener("keydown", this.onTriggerKeyDown)
      this.content && this.content.removeEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
      this._hl.unbind(this.items)
      document.removeEventListener("click", this.onDocumentClick)
    }

    this.refreshElements()
    this.bindEvents()
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => this.openMenu(),
      close: () => this.closeMenu(),
      toggle: () => {
        if (this.open) {
          this.closeMenu()
        } else {
          this.openMenu()
        }
      },
      focus: () => this.trigger?.focus(),
      clear: () => this.clearSelection(),
    })
    this.sync()
  },

  updated() {
    this.unbindEvents()
    this.refreshElements()
    this.bindEvents()
    this.sync()
  },

  destroyed() {
    this.typeahead.reset()
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Autocomplete
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `autocomplete` component.
 *
 * Combines a text input with a filterable listbox. Typing filters options
 * client-side; selecting an option writes to a hidden input for form
 * submission. Supports keyboard navigation and server-driven option lists
 * via LiveView updates.
 *
 * **Data attributes:** `data-autocomplete-input`, `data-autocomplete-content`,
 * `data-autocomplete-item`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`, `clear`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiAutocomplete = {
  mounted() {
    this.selectedLabel = this.el.dataset.selectedLabel || ""
    this.open = false
    this.skipFocusOpen = false
    this.refreshElements = () => {
      this.input = this.el.querySelector("[data-autocomplete-input]")
      this.content = this.el.querySelector("[data-autocomplete-content]")
      this.valueInput = this.el.querySelector("[data-slot='autocomplete-value']")
      this.items = Array.from(this.el.querySelectorAll("[data-autocomplete-item]"))
      this.empty = this.el.querySelector("[data-slot='autocomplete-empty']")
      this.loading = this.el.querySelector("[data-slot='autocomplete-loading']")
    }

    /** @returns {HTMLElement[]} Visible, enabled option items. */
    this.visibleItems = () =>
      this.items.filter((item) => !item.classList.contains("hidden") && item.dataset.disabled !== "true" && !item.disabled)

    this._hl = createItemHighlighter(() => this.items, () => this.sync())
    this.highlightItem = this._hl.highlight

    /** Synchronize DOM state (visibility, ARIA attributes) with `this.open`. */
    this.sync = () => {
      this.el.dataset.state = this.open ? "open" : "closed"
      if (this.input) this.input.setAttribute("aria-expanded", this.open ? "true" : "false")
      const activeItem = this.items.find((item) => item.dataset.highlighted === "true")
      if (this.input) this.input.setAttribute("aria-activedescendant", this.open && activeItem ? activeItem.id : "")
      toggleVisibility(this.content, this.open)
    }

    /** Show or hide the "no results" empty state based on visible items. */
    this.syncEmpty = () => {
      if (!this.empty) return
      if (this.el.dataset.loading === "true") {
        this.empty.classList.add("hidden")
        return
      }
      const hasVisibleItems = this.items.some((item) => !item.classList.contains("hidden"))
      this.empty.classList.toggle("hidden", hasVisibleItems)
    }

    /**
     * Commit a selection, update hidden and visible inputs, and close.
     * @param {HTMLElement} item
     */
    this.applySelection = (item) => {
      const value = item.dataset.value || ""
      const label = item.dataset.label || item.textContent.trim()

      this.selectedLabel = label
      this.el.dataset.selectedLabel = label
      if (this.input) this.input.value = label
      if (this.valueInput) this.valueInput.value = value

      this.items.forEach((entry) => {
        const selected = entry === item
        entry.dataset.selected = selected ? "true" : "false"
        entry.dataset.highlighted = "false"
        entry.setAttribute("aria-selected", selected ? "true" : "false")
        const check = entry.querySelector("[data-slot='select-check']")
        if (check) check.classList.toggle("hidden", !selected)
      })

      this.open = false
      this.sync()
      if (this.valueInput) {
        this.valueInput.dispatchEvent(new Event("input", { bubbles: true }))
        this.valueInput.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }

    /** Filter the option list by the current input value. */
    this.filterItems = () => {
      const query = (this.input?.value || "").toLowerCase()

      this.items.forEach((item) => {
        const text = (item.dataset.label || item.textContent || "").toLowerCase()
        item.classList.toggle("hidden", !text.includes(query))
      })

      if (this.valueInput && (this.input?.value || "") !== this.selectedLabel) {
        this.valueInput.value = ""
      }

      this.syncEmpty()
      this.open = true
      this.sync()
    }

    /**
     * Move focus by `delta` positions within the visible items list.
     * @param {number} delta
     */
    this.move = (delta) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) return

      const currentIndex = visibleItems.findIndex((item) => item === document.activeElement)
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + visibleItems.length) % visibleItems.length
      this.highlightItem(visibleItems[nextIndex])
      visibleItems[nextIndex].focus()
    }

    /**
     * Focus a specific visible item by index.
     * @param {number} index
     */
    this.focusVisibleItem = (index) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) return

      const nextIndex = clamp(index, 0, visibleItems.length - 1)
      this.highlightItem(visibleItems[nextIndex])
      visibleItems[nextIndex].focus()
    }

    // -- Event handlers -------------------------------------------------------

    this.onFocus = () => {
      if (this.skipFocusOpen) {
        this.skipFocusOpen = false
        return
      }
      this.open = true
      this.sync()
    }

    this.onInput = () => {
      this.filterItems()
    }

    /** @param {KeyboardEvent} event */
    this.onKeyDown = (event) => {
      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.open = true
        this.sync()
        this.move(1)
      }

      if (event.key === "ArrowUp") {
        event.preventDefault()
        this.open = true
        this.sync()
        this.move(-1)
      }

      if (event.key === "Home") {
        event.preventDefault()
        this.open = true
        this.sync()
        this.focusVisibleItem(0)
      }

      if (event.key === "End") {
        event.preventDefault()
        this.open = true
        this.sync()
        this.focusVisibleItem(this.visibleItems().length - 1)
      }

      if (event.key === "Enter") {
        const firstVisible = this.visibleItems()[0]
        if (!this.open || !firstVisible) return
        event.preventDefault()
        this.applySelection(document.activeElement?.dataset?.autocompleteItem !== undefined ? document.activeElement : firstVisible)
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.open = false
        this.sync()
        if (this.input && this.selectedLabel && !this.valueInput?.value) {
          this.input.value = this.selectedLabel
          if (this.valueInput) this.valueInput.value = this.items.find((item) => item.dataset.label === this.selectedLabel)?.dataset.value || ""
        }
        this.filterItems()
        this.open = false
        this.sync()
      }
    }

    /** @param {KeyboardEvent} event */
    this.onContentKeyDown = (event) => {
      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.move(1)
      }

      if (event.key === "ArrowUp") {
        event.preventDefault()
        this.move(-1)
      }

      if (event.key === "Home") {
        event.preventDefault()
        this.focusVisibleItem(0)
      }

      if (event.key === "End") {
        event.preventDefault()
        this.focusVisibleItem(this.visibleItems().length - 1)
      }

      if (event.key === "Enter" || event.key === " ") {
        const item = event.target.closest("[data-autocomplete-item]")
        if (!item) return
        event.preventDefault()
        this.applySelection(item)
        this.skipFocusOpen = true
        this.input?.focus()
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.open = false
        this.sync()
        this.input?.focus()
      }
    }

    this.onItemClick = (event) => {
      const item = event.currentTarget
      if (item.dataset.disabled === "true" || item.disabled) return
      this.applySelection(item)
      this.skipFocusOpen = true
      this.input?.focus()
    }

    this.onDocumentClick = (event) => {
      if (this.el.contains(event.target)) return
      this.open = false
      this.sync()
      if (this.input && this.valueInput?.value) {
        this.input.value = this.selectedLabel
      }
      this.filterItems()
      this.open = false
      this.sync()
    }

    // -- Lifecycle ------------------------------------------------------------

    this.bindEvents = () => {
      this.input?.addEventListener("focus", this.onFocus)
      this.input?.addEventListener("input", this.onInput)
      this.input?.addEventListener("keydown", this.onKeyDown)
      this.content?.addEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
      this._hl.bind(this.items)
      document.addEventListener("click", this.onDocumentClick)
    }

    this.unbindEvents = () => {
      this.input?.removeEventListener("focus", this.onFocus)
      this.input?.removeEventListener("input", this.onInput)
      this.input?.removeEventListener("keydown", this.onKeyDown)
      this.content?.removeEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
      this._hl.unbind(this.items)
      document.removeEventListener("click", this.onDocumentClick)
    }

    this.refreshElements()
    this.bindEvents()
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => {
        this.open = true
        this.sync()
      },
      close: () => {
        this.open = false
        this.sync()
      },
      toggle: () => {
        this.open = !this.open
        this.sync()
      },
      focus: () => this.input?.focus(),
      clear: () => {
        if (this.input) this.input.value = ""
        if (this.valueInput) this.valueInput.value = ""
        this.selectedLabel = ""
        this.el.dataset.selectedLabel = ""
        this.filterItems()
      },
    })
    this.syncEmpty()
    this.sync()
  },

  updated() {
    this.unbindEvents()
    this.refreshElements()
    this.selectedLabel = this.el.dataset.selectedLabel || this.selectedLabel
    this.bindEvents()
    this.syncEmpty()
    this.sync()
  },

  destroyed() {
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Input OTP
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for segmented OTP inputs.
 *
 * Auto-advances on entry, moves back on Backspace from an empty field, and
 * distributes pasted digits across the remaining inputs.
 *
 * **Data attributes:** `data-input-otp-input`, `data-input-otp-index`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiInputOtp = {
  mounted() {
    this.setup()
  },

  updated() {
    this.teardown()
    this.setup()
  },

  setup() {
    this.inputs = Array.from(this.el.querySelectorAll("[data-input-otp-input]"))
    this.cleanups = []

    const focusInput = (index) => {
      const target = this.inputs[index]
      if (!target) return
      target.focus()
      target.select()
    }

    const fillFrom = (startIndex, text) => {
      const chars = Array.from(text.replace(/\D/g, ""))
      if (!chars.length) return

      let index = startIndex
      for (const char of chars) {
        const input = this.inputs[index]
        if (!input) break
        input.value = char
        index += 1
      }

      const nextIndex = Math.min(index, this.inputs.length - 1)
      focusInput(nextIndex)
    }

    this.inputs.forEach((input, index) => {
      const onInput = () => {
        const value = input.value.replace(/\D/g, "")

        if (value.length > 1) {
          fillFrom(index, value)
          return
        }

        input.value = value
        if (value !== "" && index < this.inputs.length - 1) {
          focusInput(index + 1)
        }
      }

      const onKeyDown = (event) => {
        if (event.key === "Backspace" && input.value === "" && index > 0) {
          event.preventDefault()
          const previous = this.inputs[index - 1]
          previous.value = ""
          focusInput(index - 1)
        }

        if (event.key === "ArrowLeft" && index > 0) {
          event.preventDefault()
          focusInput(index - 1)
        }

        if (event.key === "ArrowRight" && index < this.inputs.length - 1) {
          event.preventDefault()
          focusInput(index + 1)
        }
      }

      const onPaste = (event) => {
        event.preventDefault()
        fillFrom(index, event.clipboardData?.getData("text") || "")
      }

      const onFocus = () => input.select()

      input.addEventListener("input", onInput)
      input.addEventListener("keydown", onKeyDown)
      input.addEventListener("paste", onPaste)
      input.addEventListener("focus", onFocus)

      this.cleanups.push(() => {
        input.removeEventListener("input", onInput)
        input.removeEventListener("keydown", onKeyDown)
        input.removeEventListener("paste", onPaste)
        input.removeEventListener("focus", onFocus)
      })
    })
  },

  teardown() {
    if (!this.cleanups) return
    this.cleanups.forEach((cleanup) => cleanup())
    this.cleanups = []
  },

  destroyed() {
    this.teardown()
  },
}

// -----------------------------------------------------------------------------
// MARK: Combobox
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `combobox` component.
 *
 * A lightweight text-input + dropdown that filters items by their text content.
 * Unlike {@link CuiAutocomplete}, this does not manage a hidden value input or
 * support keyboard item navigation — it is a simpler filter-and-pick control.
 *
 * **Data attributes:** `data-combobox-input`, `data-combobox-content`,
 * `data-slot="combobox-item"`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`, `clear`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiCombobox = {
  mounted() {
    this.input = this.el.querySelector("[data-combobox-input]")
    this.content = this.el.querySelector("[data-combobox-content]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='combobox-item']"))

    this.onInput = () => {
      const value = (this.input.value || "").toLowerCase()
      this.items.forEach((item) => {
        const text = item.textContent.toLowerCase()
        const visible = text.includes(value)
        item.classList.toggle("hidden", !visible)
      })
      toggleVisibility(this.content, true)
    }

    this._hl = createItemHighlighter(() => this.items)

    this.onItemClick = (event) => {
      const item = event.currentTarget
      this.input.value = item.dataset.value || item.textContent.trim()
      toggleVisibility(this.content, false)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        toggleVisibility(this.content, false)
      }
    }

    this.input && this.input.addEventListener("focus", () => toggleVisibility(this.content, true))
    this.input && this.input.addEventListener("input", this.onInput)
    this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
    this._hl.bind(this.items)
    document.addEventListener("click", this.onDocumentClick)
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => toggleVisibility(this.content, true),
      close: () => toggleVisibility(this.content, false),
      toggle: () => toggleVisibility(this.content, this.content?.classList.contains("hidden")),
      focus: () => this.input?.focus(),
      clear: () => {
        if (this.input) this.input.value = ""
        this.onInput()
      },
    })
  },

  destroyed() {
    this.input && this.input.removeEventListener("input", this.onInput)
    this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
    this._hl.unbind(this.items)
    document.removeEventListener("click", this.onDocumentClick)
    this.removeCommandListener && this.removeCommandListener()
  },
}

// -----------------------------------------------------------------------------
// MARK: Carousel
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `carousel` component.
 *
 * Translates a horizontal track by 100% per slide. Wraps around at both ends.
 *
 * **Data attributes:** `data-carousel-track`, `data-slot="carousel-item"`,
 * `data-carousel-prev`, `data-carousel-next`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiCarousel = {
  mounted() {
    this.index = 0
    this.track = this.el.querySelector("[data-carousel-track]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='carousel-item']"))
    this.prev = this.el.querySelector("[data-carousel-prev]")
    this.next = this.el.querySelector("[data-carousel-next]")

    /** Apply the CSS transform to show the current slide. */
    this.sync = () => {
      if (!this.track || this.items.length === 0) return
      const percentage = this.index * 100
      this.track.style.transform = `translateX(-${percentage}%)`
      this.track.style.transition = "transform 240ms ease"
    }

    this.onPrev = () => {
      this.index = this.index === 0 ? this.items.length - 1 : this.index - 1
      this.sync()
    }

    this.onNext = () => {
      this.index = this.index === this.items.length - 1 ? 0 : this.index + 1
      this.sync()
    }

    this.prev && this.prev.addEventListener("click", this.onPrev)
    this.next && this.next.addEventListener("click", this.onNext)
    this.sync()
  },

  destroyed() {
    this.prev && this.prev.removeEventListener("click", this.onPrev)
    this.next && this.next.removeEventListener("click", this.onNext)
  },
}

// -----------------------------------------------------------------------------
// MARK: Resizable
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `resizable` panel group component.
 *
 * Manages a set of adjacent panels separated by draggable handles. Supports
 * both horizontal and vertical layouts, per-panel minimum sizes, keyboard
 * resizing (Arrow keys, Shift for larger steps), and optional `localStorage`
 * persistence of panel sizes.
 *
 * **Data attributes:** `data-slot="resizable-panel"`,
 * `data-slot="resizable-handle"`, `data-direction`, `data-storage-key`,
 * `data-size`, `data-min-size`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
const CuiResizable = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

  /** (Re-)initialize panels, handles, sizes, and event bindings. */
  setup() {
    this.teardown()

    this.direction = this.el.dataset.direction === "vertical" ? "vertical" : "horizontal"
    this.storageKey = this.el.dataset.storageKey || null
    this.panels = Array.from(this.el.querySelectorAll(":scope > [data-slot='resizable-panel']"))
    this.handles = Array.from(this.el.querySelectorAll(":scope > [data-slot='resizable-handle']"))

    if (this.panels.length < 2) return

    this.sizes = this.loadSizes()
    this.applySizes(this.sizes)
    this.bindHandles()
  },

  /**
   * Load initial sizes from localStorage (if available), then from
   * `data-size` attributes, then from `flex-basis`, falling back to an
   * equal split.
   * @returns {number[]}
   */
  loadSizes() {
    const fromStorage = this.loadSizesFromStorage()
    if (fromStorage) return fromStorage

    const configured = this.panels.map((panel) => {
      const fromData = parsePercentage(panel.dataset.size, NaN)
      if (Number.isFinite(fromData)) return fromData
      return parsePercentage(panel.style.flexBasis, NaN)
    })

    const fallback = configured.every((value) => Number.isFinite(value))
      ? configured
      : this.panels.map(() => 100 / this.panels.length)

    return normalizePercentages(fallback)
  },

  /**
   * Attempt to restore sizes from `localStorage` using `this.storageKey`.
   * @returns {number[] | null}
   */
  loadSizesFromStorage() {
    if (!this.storageKey || !window.localStorage) return null

    try {
      const raw = window.localStorage.getItem(this.storageKey)
      if (!raw) return null
      const parsed = JSON.parse(raw)
      if (!Array.isArray(parsed) || parsed.length !== this.panels.length) return null
      const values = parsed.map((value) => Number.parseFloat(value))
      if (values.some((value) => !Number.isFinite(value))) return null
      return normalizePercentages(values)
    } catch (_error) {
      return null
    }
  },

  /** Persist current sizes to `localStorage`. */
  saveSizes() {
    if (!this.storageKey || !window.localStorage) return
    try {
      const serialized = this.sizes.map((value) => Number(value.toFixed(4)))
      window.localStorage.setItem(this.storageKey, JSON.stringify(serialized))
    } catch (_error) {
      // Ignore localStorage errors.
    }
  },

  /**
   * Return the minimum percentage size for the panel at `index`.
   * @param {number} index
   * @returns {number}
   */
  panelMinSize(index) {
    return parsePercentage(this.panels[index]?.dataset.minSize, 10)
  },

  /**
   * Return the pointer coordinate along the resize axis.
   * @param {PointerEvent} event
   * @returns {number}
   */
  axisCoordinate(event) {
    return this.direction === "horizontal" ? event.clientX : event.clientY
  },

  /**
   * Return the container's pixel length along the resize axis.
   * @returns {number}
   */
  axisLength() {
    const rect = this.el.getBoundingClientRect()
    return this.direction === "horizontal" ? rect.width : rect.height
  },

  /**
   * Apply a new set of panel sizes, normalizing them and updating the DOM.
   * @param {number[]} nextSizes
   */
  applySizes(nextSizes) {
    this.sizes = normalizePercentages(nextSizes)
    this.panels.forEach((panel, index) => {
      const size = this.sizes[index]
      panel.style.flex = `0 0 ${size}%`
      panel.dataset.size = String(Number(size.toFixed(4)))
    })
  },

  /**
   * Resize the panel pair at `index` / `index + 1` by `deltaPercent`,
   * respecting minimum sizes.
   * @param {number} index
   * @param {number} deltaPercent
   */
  adjustPair(index, deltaPercent) {
    const leftIndex = index
    const rightIndex = index + 1
    const leftSize = this.sizes[leftIndex]
    const rightSize = this.sizes[rightIndex]
    const pairTotal = leftSize + rightSize
    const leftMin = this.panelMinSize(leftIndex)
    const rightMin = this.panelMinSize(rightIndex)

    const nextLeft = clamp(leftSize + deltaPercent, leftMin, pairTotal - rightMin)
    const nextRight = pairTotal - nextLeft
    const nextSizes = [...this.sizes]
    nextSizes[leftIndex] = nextLeft
    nextSizes[rightIndex] = nextRight
    this.applySizes(nextSizes)
    this.saveSizes()
  },

  /** Bind pointer and keyboard events to each resize handle. */
  bindHandles() {
    this.cleanups = []

    this.handles.forEach((handle, index) => {
      if (index >= this.panels.length - 1) return

      const onPointerDown = (event) => {
        event.preventDefault()

        const startCoord = this.axisCoordinate(event)
        const startSizes = [...this.sizes]
        const length = this.axisLength()
        if (!length || length <= 0) return

        const leftIndex = index
        const rightIndex = index + 1
        const pairTotal = startSizes[leftIndex] + startSizes[rightIndex]
        const leftMin = this.panelMinSize(leftIndex)
        const rightMin = this.panelMinSize(rightIndex)

        const onPointerMove = (moveEvent) => {
          const deltaPixels = this.axisCoordinate(moveEvent) - startCoord
          const deltaPercent = (deltaPixels / length) * 100
          const nextLeft = clamp(startSizes[leftIndex] + deltaPercent, leftMin, pairTotal - rightMin)
          const nextRight = pairTotal - nextLeft
          const nextSizes = [...this.sizes]
          nextSizes[leftIndex] = nextLeft
          nextSizes[rightIndex] = nextRight
          this.applySizes(nextSizes)
        }

        const onPointerUp = () => {
          window.removeEventListener("pointermove", onPointerMove)
          window.removeEventListener("pointerup", onPointerUp)
          window.removeEventListener("pointercancel", onPointerUp)
          this.saveSizes()
        }

        window.addEventListener("pointermove", onPointerMove)
        window.addEventListener("pointerup", onPointerUp)
        window.addEventListener("pointercancel", onPointerUp)
      }

      /** @param {KeyboardEvent} event */
      const onKeyDown = (event) => {
        const step = event.shiftKey ? 10 : 2

        if (this.direction === "horizontal" && event.key === "ArrowLeft") {
          event.preventDefault()
          this.adjustPair(index, -step)
        }

        if (this.direction === "horizontal" && event.key === "ArrowRight") {
          event.preventDefault()
          this.adjustPair(index, step)
        }

        if (this.direction === "vertical" && event.key === "ArrowUp") {
          event.preventDefault()
          this.adjustPair(index, -step)
        }

        if (this.direction === "vertical" && event.key === "ArrowDown") {
          event.preventDefault()
          this.adjustPair(index, step)
        }
      }

      handle.addEventListener("pointerdown", onPointerDown)
      handle.addEventListener("keydown", onKeyDown)

      this.cleanups.push(() => {
        handle.removeEventListener("pointerdown", onPointerDown)
        handle.removeEventListener("keydown", onKeyDown)
      })
    })
  },

  /** Remove all handle event listeners. */
  teardown() {
    if (this.cleanups) {
      this.cleanups.forEach((cleanup) => cleanup())
    }
    this.cleanups = []
  },

  destroyed() {
    this.teardown()
  },
}

// -----------------------------------------------------------------------------
// MARK: Exports
// -----------------------------------------------------------------------------

/**
 * All CinderUI Phoenix LiveView hooks. Register these with your LiveSocket:
 *
 * ```js
 * import { CinderUIHooks } from "./cinder_ui"
 * const liveSocket = new LiveSocket("/live", Socket, {
 *   hooks: { ...CinderUIHooks },
 * })
 * ```
 */
export const CinderUIHooks = {
  CuiDialog,
  CuiDrawer,
  CuiSheet,
  CuiPopover,
  CuiDropdownMenu,
  CuiMenubar,
  CuiSelect,
  CuiAutocomplete,
  CuiInputOtp,
  CuiCombobox,
  CuiCarousel,
  CuiResizable,
}

/**
 * Public API for imperative component control from outside LiveView hooks.
 *
 * ```js
 * import { CinderUI } from "./cinder_ui"
 * CinderUI.dispatchCommand(document.getElementById("my-dialog"), "open")
 * ```
 */
export const CinderUI = {
  dispatchCommand,
}
