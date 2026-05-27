import { toggleVisibility } from "../dom.js"
import { registerCommandListener } from "../commands.js"
import { focusFirst, getFocusTarget, restoreFocus } from "../focus.js"

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
export const CuiPopover = {
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
