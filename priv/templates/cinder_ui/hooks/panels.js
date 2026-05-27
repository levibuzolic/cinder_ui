import { toggleVisibility, clickClosest } from "../dom.js"
import { registerCommandListener } from "../commands.js"
import { focusFirst, getFocusTarget, restoreFocus } from "../focus.js"
import { applyInert, removeInert } from "../inert.js"

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
export const createPanelHook = (config) => ({
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
export const CuiDrawer = createPanelHook({
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
export const CuiSheet = createPanelHook({
  triggerSelector: "[data-sheet-trigger]",
  overlaySelector: "[data-sheet-overlay]",
  contentSelector: "[data-sheet-content]",
})
