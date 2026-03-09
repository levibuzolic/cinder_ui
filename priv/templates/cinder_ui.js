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

const clickClosest = (target, selector) => target && target.closest(selector)
const clamp = (value, min, max) => Math.min(Math.max(value, min), max)
const COMMAND_EVENT = "cinder-ui:command"
const FOCUSABLE_SELECTOR =
  "button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])"

const parsePercentage = (value, fallback) => {
  if (value === null || value === undefined || value === "") return fallback
  const parsed = Number.parseFloat(value)
  return Number.isFinite(parsed) ? parsed : fallback
}

const normalizePercentages = (values) => {
  if (!values.length) return values
  const total = values.reduce((sum, value) => sum + value, 0)
  if (total <= 0) return values.map(() => 100 / values.length)
  return values.map((value) => (value / total) * 100)
}

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

const dispatchCommand = (target, command, detail = {}) => {
  if (!target) return
  target.dispatchEvent(
    new CustomEvent(COMMAND_EVENT, {
      bubbles: false,
      detail: { ...detail, command },
    }),
  )
}

const getFocusableElements = (root) =>
  root ? Array.from(root.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) => !el.hasAttribute("hidden")) : []

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

const getFocusTarget = (root) => getFocusableElements(root)[0] || root || null

const restoreFocus = (preferred, fallback) => {
  if (preferred && document.contains(preferred) && typeof preferred.focus === "function") {
    preferred.focus()
    return
  }

  if (fallback && document.contains(fallback) && typeof fallback.focus === "function") {
    fallback.focus()
  }
}

const CuiDialog = {
  mounted() {
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-dialog-trigger]")
      this.content = this.el.querySelector("[data-dialog-content]")
    }

    this.refreshElements()
    this.lastActiveElement = null
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
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleEvent)
    document.removeEventListener("keydown", this.onKeydown)
    this.removeCommandListener && this.removeCommandListener()
  },
}

const createPanelHook = (config) => ({
  mounted() {
    this.refreshElements = () => {
      this.trigger = this.el.querySelector(config.triggerSelector)
      this.content = this.el.querySelector(config.contentSelector)
    }

    this.refreshElements()
    this.lastActiveElement = null
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
      window.requestAnimationFrame(() => focusFirst(this.content))
    }

    if (!open && wasOpen) {
      restoreFocus(this.lastActiveElement, this.trigger)
    }
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleEvent)
    document.removeEventListener("keydown", this.onKeydown)
    this.removeCommandListener && this.removeCommandListener()
  },
})

const CuiDrawer = createPanelHook({
  triggerSelector: "[data-drawer-trigger]",
  overlaySelector: "[data-drawer-overlay]",
  contentSelector: "[data-drawer-content]",
})

const CuiSheet = createPanelHook({
  triggerSelector: "[data-sheet-trigger]",
  overlaySelector: "[data-sheet-overlay]",
  contentSelector: "[data-sheet-content]",
})

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

const CuiDropdownMenu = {
  mounted() {
    this.open = false
    this.lastActiveElement = null
    this.refreshElements = () => {
      this.trigger = this.el.querySelector("[data-dropdown-trigger]")
      this.content = this.el.querySelector("[data-dropdown-content]")
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

    this.enabledItems = () => this.items.filter((item) => item.dataset.disabled !== "true" && !item.disabled)

    this.selectedIndex = () =>
      this.items.findIndex((item) => item.dataset.selected === "true")

    this.highlightItem = (target) => {
      this.items.forEach((item) => {
        const highlighted = item === target
        item.dataset.highlighted = highlighted ? "true" : "false"
      })
    }

    this.sync = () => {
      this.el.dataset.state = this.open ? "open" : "closed"
      if (this.trigger) this.trigger.setAttribute("aria-expanded", this.open ? "true" : "false")
      const activeItem = this.items.find((item) => item.dataset.highlighted === "true")
      if (this.trigger) this.trigger.setAttribute("aria-activedescendant", this.open && activeItem ? activeItem.id : "")
      toggleVisibility(this.content, this.open)
    }

    this.focusItem = (index) => {
      const enabledItems = this.enabledItems()
      if (!enabledItems.length) return

      const nextIndex = Math.min(Math.max(index, 0), enabledItems.length - 1)
      this.highlightItem(enabledItems[nextIndex])
      enabledItems[nextIndex].focus()
    }

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

    this.closeMenu = () => {
      if (!this.open) return
      this.open = false
      this.sync()
    }

    this.selectItem = (item) => {
      const value = item.dataset.value || ""
      const label = item.dataset.label || item.textContent.trim()

      if (this.input) this.input.value = value
      this.items.forEach((entry) => {
        const selected = entry === item
        entry.dataset.selected = selected ? "true" : "false"
        entry.dataset.highlighted = "false"
        entry.setAttribute("aria-selected", selected ? "true" : "false")
        entry.classList.toggle("bg-accent", selected)
        entry.classList.toggle("text-accent-foreground", selected)
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

    this.clearSelection = () => {
      const placeholder = this.el.dataset.placeholder || ""
      if (this.input) this.input.value = ""
      this.items.forEach((entry) => {
        entry.dataset.selected = "false"
        entry.dataset.highlighted = "false"
        entry.setAttribute("aria-selected", "false")
        entry.classList.remove("bg-accent", "text-accent-foreground")
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

    this.move = (delta, current) => {
      const enabledItems = this.enabledItems()
      if (!enabledItems.length) return

      const currentIndex = enabledItems.indexOf(current)
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + enabledItems.length) % enabledItems.length
      enabledItems[nextIndex].focus()
    }

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
    }

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
    }

    this.onItemClick = (event) => {
      const item = event.currentTarget
      if (item.dataset.disabled === "true" || item.disabled) return
      this.selectItem(item)
    }

    this.onItemFocus = (event) => {
      this.highlightItem(event.currentTarget)
      this.sync()
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) this.closeMenu()
    }

    this.bindEvents = () => {
      this.trigger && this.trigger.addEventListener("click", this.onTriggerClick)
      this.clearButton && this.clearButton.addEventListener("click", this.onClearClick)
      this.trigger && this.trigger.addEventListener("keydown", this.onTriggerKeyDown)
      this.content && this.content.addEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
      this.items.forEach((item) => item.addEventListener("focus", this.onItemFocus))
      document.addEventListener("click", this.onDocumentClick)
    }

    this.unbindEvents = () => {
      this.trigger && this.trigger.removeEventListener("click", this.onTriggerClick)
      this.clearButton && this.clearButton.removeEventListener("click", this.onClearClick)
      this.trigger && this.trigger.removeEventListener("keydown", this.onTriggerKeyDown)
      this.content && this.content.removeEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
      this.items.forEach((item) => item.removeEventListener("focus", this.onItemFocus))
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
    this.unbindEvents()
    this.removeCommandListener && this.removeCommandListener()
  },
}

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

    this.visibleItems = () =>
      this.items.filter((item) => !item.classList.contains("hidden") && item.dataset.disabled !== "true" && !item.disabled)

    this.highlightItem = (target) => {
      this.items.forEach((item) => {
        const highlighted = item === target
        item.dataset.highlighted = highlighted ? "true" : "false"
      })
    }

    this.sync = () => {
      this.el.dataset.state = this.open ? "open" : "closed"
      if (this.input) this.input.setAttribute("aria-expanded", this.open ? "true" : "false")
      const activeItem = this.items.find((item) => item.dataset.highlighted === "true")
      if (this.input) this.input.setAttribute("aria-activedescendant", this.open && activeItem ? activeItem.id : "")
      toggleVisibility(this.content, this.open)
    }

    this.syncEmpty = () => {
      if (!this.empty) return
      if (this.el.dataset.loading === "true") {
        this.empty.classList.add("hidden")
        return
      }
      const hasVisibleItems = this.items.some((item) => !item.classList.contains("hidden"))
      this.empty.classList.toggle("hidden", hasVisibleItems)
    }

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
        entry.classList.toggle("bg-accent", selected)
        entry.classList.toggle("text-accent-foreground", selected)
      })

      this.open = false
      this.sync()
      if (this.valueInput) {
        this.valueInput.dispatchEvent(new Event("input", { bubbles: true }))
        this.valueInput.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }

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

    this.move = (delta) => {
      const visibleItems = this.visibleItems()
      if (!visibleItems.length) return

      const currentIndex = visibleItems.findIndex((item) => item === document.activeElement)
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + visibleItems.length) % visibleItems.length
      this.highlightItem(visibleItems[nextIndex])
      visibleItems[nextIndex].focus()
    }

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

    this.onContentKeyDown = (event) => {
      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.move(1)
      }

      if (event.key === "ArrowUp") {
        event.preventDefault()
        this.move(-1)
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

    this.onItemFocus = (event) => {
      this.highlightItem(event.currentTarget)
      this.sync()
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

    this.bindEvents = () => {
      this.input?.addEventListener("focus", this.onFocus)
      this.input?.addEventListener("input", this.onInput)
      this.input?.addEventListener("keydown", this.onKeyDown)
      this.content?.addEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
      this.items.forEach((item) => item.addEventListener("focus", this.onItemFocus))
      document.addEventListener("click", this.onDocumentClick)
    }

    this.unbindEvents = () => {
      this.input?.removeEventListener("focus", this.onFocus)
      this.input?.removeEventListener("input", this.onInput)
      this.input?.removeEventListener("keydown", this.onKeyDown)
      this.content?.removeEventListener("keydown", this.onContentKeyDown)
      this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
      this.items.forEach((item) => item.removeEventListener("focus", this.onItemFocus))
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
    document.removeEventListener("click", this.onDocumentClick)
    this.removeCommandListener && this.removeCommandListener()
  },
}

const CuiCarousel = {
  mounted() {
    this.index = 0
    this.track = this.el.querySelector("[data-carousel-track]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='carousel-item']"))
    this.prev = this.el.querySelector("[data-carousel-prev]")
    this.next = this.el.querySelector("[data-carousel-next]")

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

const CuiResizable = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

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

  saveSizes() {
    if (!this.storageKey || !window.localStorage) return
    try {
      const serialized = this.sizes.map((value) => Number(value.toFixed(4)))
      window.localStorage.setItem(this.storageKey, JSON.stringify(serialized))
    } catch (_error) {
      // Ignore localStorage errors.
    }
  },

  panelMinSize(index) {
    return parsePercentage(this.panels[index]?.dataset.minSize, 10)
  },

  axisCoordinate(event) {
    return this.direction === "horizontal" ? event.clientX : event.clientY
  },

  axisLength() {
    const rect = this.el.getBoundingClientRect()
    return this.direction === "horizontal" ? rect.width : rect.height
  },

  applySizes(nextSizes) {
    this.sizes = normalizePercentages(nextSizes)
    this.panels.forEach((panel, index) => {
      const size = this.sizes[index]
      panel.style.flex = `0 0 ${size}%`
      panel.dataset.size = String(Number(size.toFixed(4)))
    })
  },

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

export const CinderUIHooks = {
  CuiDialog,
  CuiDrawer,
  CuiSheet,
  CuiPopover,
  CuiDropdownMenu,
  CuiSelect,
  CuiAutocomplete,
  CuiCombobox,
  CuiCarousel,
  CuiResizable,
}

export const CinderUI = {
  dispatchCommand,
}
