const roles = {
  levi: "engineering engineer backend elixir",
  mira: "design designer product ux",
  sam: "operations ops support",
}

// Reuse the rendered options; this fixture only simulates which results a server returns.
export const withAutocompleteSearchDemo = (definition) => ({
  ...definition,
  mounted() {
    definition.mounted.call(this)
    if (!["owner-search", "on-demand-owner-search"].includes(this.el.id)) return

    const filterItems = this.filterItems
    const pushEvent = this.pushEvent
    let terms = []
    let timer
    const loading = document.createElement("div")
    loading.setAttribute("role", "status")
    loading.className = "text-muted-foreground hidden px-2 py-1.5 text-sm"
    loading.textContent = "Searching teammates…"
    this.content.insertBefore(loading, this.empty)

    const renderResults = (options) => {
      const busy = this.el.dataset.loading === "true"
      loading.classList.toggle("hidden", !busy)
      if (this.searchButton) this.searchButton.disabled = busy || this.input.disabled
      this.items.forEach((item) => {
        const text = `${item.dataset.label} ${roles[item.dataset.value]}`.toLowerCase()
        item.classList.toggle("hidden", busy || !terms.every((term) => text.includes(term)))
      })
      this.syncGroups()
      this.syncEmpty()
      if (this.isManualSearch()) this.highlightItem(null)
      else this.highlightVisibleDefault(options)
    }

    const search = (query, delay = 500) => {
      window.clearTimeout(timer)
      this.el.dataset.loading = "true"
      renderResults()
      timer = window.setTimeout(() => {
        terms = query.toLowerCase().trim().split(/\s+/).filter(Boolean)
        this.el.dataset.loading = "false"
        renderResults()
      }, delay)
    }
    const onInput = () => search(this.input.value, 800)
    if (!this.isManualSearch()) this.input.addEventListener("input", onInput)
    this.filterItems = (options) => {
      filterItems(options)
      renderResults(options)
    }
    this.pushEvent = (event, payload) => {
      if (event !== this.el.dataset.searchEvent) return pushEvent.call(this, event, payload)
      search(payload.query)
      return Promise.resolve()
    }
    this.cleanupSearchDemo = () => {
      window.clearTimeout(timer)
      this.input.removeEventListener("input", onInput)
      this.filterItems = filterItems
      this.pushEvent = pushEvent
      loading.remove()
    }
  },
  destroyed() {
    this.cleanupSearchDemo?.()
    definition.destroyed.call(this)
  },
})
