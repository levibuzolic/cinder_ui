import { registerCommandListener } from "../commands.js"

// -----------------------------------------------------------------------------
// MARK: Sidebar
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the simplified `sidebar` component.
 *
 * Manages expanded/collapsed state, keeps trigger ARIA attributes in sync, and
 * optionally persists the state in `localStorage`.
 *
 * **Data attributes:** `data-sidebar-trigger`, `data-state`,
 * `data-sidebar-persist-key`, `data-collapsible`.
 *
 * **Commands:** `expand`, `collapse`, `toggle`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiSidebar = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

  destroyed() {
    this.teardown()
  },

  setup() {
    this.teardown()

    this.persistKey = this.el.dataset.sidebarPersistKey || null
    this.controlled = this.el.hasAttribute("data-sidebar-controlled")
    this.toggleEvent = this.el.dataset.sidebarToggleEvent || null
    this.collapsible = this.el.dataset.collapsible || "icon"
    this.triggers = Array.from(this.el.querySelectorAll("[data-sidebar-trigger]"))
    this.cleanups = []

    const persistedState = this.controlled ? null : this.readPersistedState()
    this.state = persistedState || (this.el.dataset.state === "collapsed" ? "collapsed" : "expanded")

    this.sync = (nextState) => {
      const resolvedState = nextState === "collapsed" && this.collapsible === "icon" ? "collapsed" : "expanded"
      this.state = resolvedState
      this.el.dataset.state = resolvedState

      this.triggers.forEach((trigger) => {
        trigger.setAttribute("aria-expanded", resolvedState === "expanded" ? "true" : "false")
      })

      if (!this.controlled) this.persistState(resolvedState)
    }

    this.toggle = () => {
      const nextState = this.state === "collapsed" ? "expanded" : "collapsed"

      if (this.controlled) {
        if (this.toggleEvent) {
          this.pushEvent(this.toggleEvent, { open: nextState === "expanded" })
        }

        this.sync(this.el.dataset.state === "collapsed" ? "collapsed" : "expanded")
        return
      }

      this.sync(nextState)
    }

    this.triggers.forEach((trigger) => {
      const onClick = (event) => {
        event.preventDefault()
        this.toggle()
      }

      const onKeydown = (event) => {
        if (event.key !== "Enter" && event.key !== " ") return
        event.preventDefault()
        this.toggle()
      }

      trigger.addEventListener("click", onClick)
      trigger.addEventListener("keydown", onKeydown)
      this.cleanups.push(() => {
        trigger.removeEventListener("click", onClick)
        trigger.removeEventListener("keydown", onKeydown)
      })
    })

    this.removeCommandListener = registerCommandListener(this.el, {
      expand: () => this.sync("expanded"),
      collapse: () => this.sync("collapsed"),
      toggle: () => this.toggle(),
    })

    this.sync(this.state)
  },

  teardown() {
    if (this.cleanups) this.cleanups.forEach((cleanup) => cleanup())
    this.cleanups = []
    this.removeCommandListener && this.removeCommandListener()
    this.removeCommandListener = null
  },

  readPersistedState() {
    if (!this.persistKey) return null

    try {
      const value = window.localStorage.getItem(this.persistKey)
      return value === "collapsed" || value === "expanded" ? value : null
    } catch (_error) {
      return null
    }
  },

  persistState(state) {
    if (!this.persistKey) return

    try {
      window.localStorage.setItem(this.persistKey, state)
    } catch (_error) {}
  },
}
