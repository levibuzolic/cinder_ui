import { toggleVisibility, clamp, createItemHighlighter } from "../dom.js"
import { registerCommandListener } from "../commands.js"

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
export const CuiAutocomplete = {
  mounted() {
    this.selectedLabel = this.el.dataset.selectedLabel || ""
    this.selectedValue = ""
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

    /**
     * Highlight the selected visible item or first visible item.
     * @param {{ preferSelection?: boolean }} [options]
     * @returns {HTMLElement | null}
     */
    this.highlightVisibleDefault = ({ preferSelection = false } = {}) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) {
        this.highlightItem(null)
        return null
      }

      const target = preferSelection
        ? visibleItems.find((item) => item.dataset.selected === "true") || visibleItems[0]
        : visibleItems[0]

      this.highlightItem(target)
      return target
    }

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
      this.selectedValue = value
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

    /**
     * Filter the option list by the current input value.
     * @param {{ preferSelection?: boolean }} [options]
     */
    this.filterItems = ({ preferSelection = false } = {}) => {
      const query = (this.input?.value || "").toLowerCase()

      this.items.forEach((item) => {
        const text = (item.dataset.label || item.textContent || "").toLowerCase()
        item.classList.toggle("hidden", !text.includes(query))
      })

      if (this.valueInput && (this.input?.value || "") !== this.selectedLabel) {
        this.valueInput.value = ""
      }

      this.syncEmpty()
      this.highlightVisibleDefault({ preferSelection })
      this.open = true
      this.sync()
    }

    /** Restore the last committed selection and close the list. */
    this.restoreSelection = () => {
      if (this.input) this.input.value = this.selectedLabel
      if (this.valueInput) this.valueInput.value = this.selectedValue
      this.filterItems({ preferSelection: true })
      this.open = false
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
      this.highlightVisibleDefault({ preferSelection: true })
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
        const highlighted = this.visibleItems().find((item) => item.dataset.highlighted === "true")
        this.applySelection(document.activeElement?.dataset?.autocompleteItem !== undefined ? document.activeElement : highlighted || firstVisible)
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.restoreSelection()
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
      this.restoreSelection()
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
    this.selectedValue = this.valueInput?.value || ""
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
        this.selectedValue = ""
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
    this.selectedLabel = this.el.dataset.selectedLabel ?? this.selectedLabel
    this.selectedValue = this.valueInput?.value ?? this.selectedValue
    this.bindEvents()
    this.syncEmpty()
    this.sync()
  },

  destroyed() {
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}
