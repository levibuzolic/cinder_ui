import { clamp, parsePercentage, normalizePercentages } from "../dom.js"

// -----------------------------------------------------------------------------
// MARK: Resizable
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `resizable` panel group component.
 *
 * Manages a set of adjacent panels separated by draggable handles. Supports
 * both horizontal and vertical layouts, per-panel minimum sizes, keyboard
 * resizing (Arrow keys, Shift for larger steps), and optional `localStorage`
 * persistence of panel sizes.
 *
 * **Data attributes:** `data-slot="resizable-panel"`,
 * `data-slot="resizable-handle"`, `data-direction`, `data-storage-key`,
 * `data-size`, `data-min-size`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiResizable = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

  /** (Re-)initialize panels, handles, sizes, and event bindings. */
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

  /**
   * Load initial sizes from localStorage (if available), then from
   * `data-size` attributes, then from `flex-basis`, falling back to an
   * equal split.
   * @returns {number[]}
   */
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

  /**
   * Attempt to restore sizes from `localStorage` using `this.storageKey`.
   * @returns {number[] | null}
   */
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

  /** Persist current sizes to `localStorage`. */
  saveSizes() {
    if (!this.storageKey || !window.localStorage) return
    try {
      const serialized = this.sizes.map((value) => Number(value.toFixed(4)))
      window.localStorage.setItem(this.storageKey, JSON.stringify(serialized))
    } catch (_error) {
      // Ignore localStorage errors.
    }
  },

  /**
   * Return the minimum percentage size for the panel at `index`.
   * @param {number} index
   * @returns {number}
   */
  panelMinSize(index) {
    return parsePercentage(this.panels[index]?.dataset.minSize, 10)
  },

  /**
   * Return the pointer coordinate along the resize axis.
   * @param {PointerEvent} event
   * @returns {number}
   */
  axisCoordinate(event) {
    return this.direction === "horizontal" ? event.clientX : event.clientY
  },

  /**
   * Return the container's pixel length along the resize axis.
   * @returns {number}
   */
  axisLength() {
    const rect = this.el.getBoundingClientRect()
    return this.direction === "horizontal" ? rect.width : rect.height
  },

  /**
   * Apply a new set of panel sizes, normalizing them and updating the DOM.
   * @param {number[]} nextSizes
   */
  applySizes(nextSizes) {
    this.sizes = normalizePercentages(nextSizes)
    this.panels.forEach((panel, index) => {
      const size = this.sizes[index]
      panel.style.flex = `0 0 ${size}%`
      panel.dataset.size = String(Number(size.toFixed(4)))
    })
  },

  /**
   * Resize the panel pair at `index` / `index + 1` by `deltaPercent`,
   * respecting minimum sizes.
   * @param {number} index
   * @param {number} deltaPercent
   */
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

  /** Bind pointer and keyboard events to each resize handle. */
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

      /** @param {KeyboardEvent} event */
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

  /** Remove all handle event listeners. */
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
