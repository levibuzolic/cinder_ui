import { toggleVisibility, clickClosest } from "../dom.js"
import { focusFirst } from "../focus.js"

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
export const CuiMenubar = {
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
