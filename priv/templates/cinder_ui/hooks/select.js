import { toggleVisibility, createItemHighlighter, createTypeaheadMatcher } from "../dom.js"
import { registerCommandListener } from "../commands.js"

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
export const CuiSelect = {
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
