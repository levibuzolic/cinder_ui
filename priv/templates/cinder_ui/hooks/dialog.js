import { toggleVisibility, clickClosest } from "../dom.js"
import { registerCommandListener } from "../commands.js"
import { focusFirst, getFocusTarget, restoreFocus } from "../focus.js"
import { applyInert, removeInert } from "../inert.js"

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
export const CuiDialog = {
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
