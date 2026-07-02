import { toggleVisibility, clamp, createItemHighlighter } from "../dom.js"
import { registerCommandListener } from "../commands.js"

// -----------------------------------------------------------------------------
// MARK: Combobox
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `combobox` component.
 *
 * A lightweight text-input + dropdown that filters items by their text content.
 * Unlike {@link CuiAutocomplete}, this does not manage a hidden value input,
 * but it does keep an active item so Enter can accept the top suggestion.
 *
 * **Data attributes:** `data-combobox-input`, `data-combobox-content`,
 * `data-slot="combobox-item"`.
 *
 * **Commands:** `open`, `close`, `toggle`, `focus`, `clear`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiCombobox = {
  mounted() {
    this.input = this.el.querySelector("[data-combobox-input]")
    this.content = this.el.querySelector("[data-combobox-content]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='combobox-item']"))
    this.groups = Array.from(this.el.querySelectorAll("[data-combobox-group]"))
    this.committedValue = this.input?.value || ""
    this.open = this.el.dataset.state === "open"

    /** @returns {HTMLElement[]} Visible combobox items. */
    this.visibleItems = () => this.items.filter((item) => !item.classList.contains("hidden"))

    this._hl = createItemHighlighter(() => this.items, () => this.sync())
    this.highlightItem = this._hl.highlight

    /** Synchronize visibility and active descendant state. */
    this.sync = () => {
      if (this.input) {
        this.input.setAttribute("aria-expanded", this.open ? "true" : "false")
        const activeItem = this.items.find((item) => item.dataset.highlighted === "true")
        this.input.setAttribute("aria-activedescendant", this.open && activeItem?.id ? activeItem.id : "")
      }
      toggleVisibility(this.content, this.open)
    }

    /**
     * Highlight the first visible item.
     * @returns {HTMLElement | null}
     */
    this.highlightFirstVisible = () => {
      const firstVisible = this.visibleItems()[0] || null
      this.highlightItem(firstVisible)
      return firstVisible
    }

    /** Hide group wrappers whose child items are all filtered out. */
    this.syncGroups = () => {
      this.groups.forEach((group) => {
        const hasVisibleItems = Array.from(group.querySelectorAll("[data-slot='combobox-item']")).some(
          (item) => !item.classList.contains("hidden")
        )
        group.classList.toggle("hidden", !hasVisibleItems)
      })
    }

    /** Filter options using the current input text and highlight the top match. */
    this.filterItems = () => {
      const value = (this.input.value || "").toLowerCase()
      this.items.forEach((item) => {
        const text = (item.dataset.label || item.textContent || "").toLowerCase()
        const visible = text.includes(value)
        item.classList.toggle("hidden", !visible)
      })
      this.syncGroups()
      this.highlightFirstVisible()
      this.open = true
      this.sync()
    }

    /**
     * Focus a visible item by index.
     * @param {number} index
     */
    this.focusVisibleItem = (index) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) return

      const nextIndex = clamp(index, 0, visibleItems.length - 1)
      this.highlightItem(visibleItems[nextIndex])
      visibleItems[nextIndex].focus()
    }

    /**
     * Move focus within the visible item list.
     * @param {number} delta
     */
    this.move = (delta) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) return

      const currentIndex = visibleItems.findIndex((item) => item === document.activeElement)
      const highlightedIndex = visibleItems.findIndex((item) => item.dataset.highlighted === "true")

      if (currentIndex === -1) {
        const fallbackIndex = highlightedIndex === -1 ? 0 : highlightedIndex
        this.focusVisibleItem(fallbackIndex)
        return
      }

      const nextIndex = (currentIndex + delta + visibleItems.length) % visibleItems.length
      this.focusVisibleItem(nextIndex)
    }

    /**
     * Commit a combobox item.
     * @param {HTMLElement} item
     */
    this.applySelection = (item) => {
      this.committedValue = item.dataset.label || item.dataset.value || item.textContent.trim()
      if (this.input) this.input.value = this.committedValue
      this.items.forEach((entry) => {
        const selected = entry === item
        entry.dataset.selected = selected ? "true" : "false"
        entry.setAttribute("aria-selected", selected ? "true" : "false")
        const check = entry.querySelector("[data-slot='select-check']")
        if (check) check.classList.toggle("hidden", !selected)
      })
      this.open = false
      this.highlightItem(null)
      this.sync()
    }

    /** Restore the last committed value without selecting the current highlight. */
    this.restoreSelection = () => {
      if (this.input) this.input.value = this.committedValue
      this.filterItems()
      this.open = false
      this.sync()
    }

    this.onItemClick = (event) => {
      const item = event.currentTarget
      this.applySelection(item)
      this.input?.focus()
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        this.restoreSelection()
      }
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
        const highlighted = this.visibleItems().find((item) => item.dataset.highlighted === "true")
        if (!this.open || !highlighted) return
        event.preventDefault()
        this.applySelection(highlighted)
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
        const item = event.target.closest("[data-slot='combobox-item']")
        if (!item) return
        event.preventDefault()
        this.applySelection(item)
        this.input?.focus()
      }

      if (event.key === "Escape") {
        event.preventDefault()
        this.restoreSelection()
        this.input?.focus()
      }
    }

    this.onFocus = (event) => {
      if (!event.relatedTarget || !this.content?.contains(event.relatedTarget)) {
        this.filterItems()
      }
    }

    this.onInput = () => {
      this.filterItems()
    }

    this.input && this.input.addEventListener("focus", this.onFocus)
    this.input && this.input.addEventListener("input", this.onInput)
    this.input && this.input.addEventListener("keydown", this.onKeyDown)
    this.content && this.content.addEventListener("keydown", this.onContentKeyDown)
    this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
    this._hl.bind(this.items)
    document.addEventListener("click", this.onDocumentClick)
    this.removeCommandListener = registerCommandListener(this.el, {
      open: () => {
        this.open = true
        this.highlightFirstVisible()
        this.sync()
      },
      close: () => {
        this.open = false
        this.highlightItem(null)
        this.sync()
      },
      toggle: () => {
        this.open = !this.open
        if (this.open) {
          this.highlightFirstVisible()
        } else {
          this.highlightItem(null)
        }
        this.sync()
      },
      focus: () => this.input?.focus(),
      clear: () => {
        this.committedValue = ""
        if (this.input) this.input.value = ""
        this.items.forEach((entry) => {
          entry.dataset.selected = "false"
          entry.setAttribute("aria-selected", "false")
          const check = entry.querySelector("[data-slot='select-check']")
          if (check) check.classList.add("hidden")
        })
        this.filterItems()
      },
    })
    this.sync()
  },

  destroyed() {
    this.input && this.input.removeEventListener("focus", this.onFocus)
    this.input && this.input.removeEventListener("input", this.onInput)
    this.input && this.input.removeEventListener("keydown", this.onKeyDown)
    this.content && this.content.removeEventListener("keydown", this.onContentKeyDown)
    this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
    this._hl.unbind(this.items)
    document.removeEventListener("click", this.onDocumentClick)
    this.removeCommandListener && this.removeCommandListener()
  },
}
