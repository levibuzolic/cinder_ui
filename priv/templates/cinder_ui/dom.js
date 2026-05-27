// -----------------------------------------------------------------------------
// MARK: Utilities
// -----------------------------------------------------------------------------

/**
 * Toggle an element's visibility by adding/removing the `hidden` class and
 * setting `data-state` to `"open"` or `"closed"`.
 * @param {HTMLElement | null} el
 * @param {boolean} visible
 */
export const toggleVisibility = (el, visible) => {
  if (!el) return
  if (visible) {
    el.classList.remove("hidden")
    el.dataset.state = "open"
  } else {
    el.classList.add("hidden")
    el.dataset.state = "closed"
  }
}

/**
 * Walk up from `target` to find the nearest ancestor matching `selector`.
 * Returns the matched element or `null`.
 * @param {EventTarget | null} target
 * @param {string} selector
 * @returns {HTMLElement | null}
 */
export const clickClosest = (target, selector) => target && target.closest(selector)

/**
 * Clamp `value` between `min` and `max` (inclusive).
 * @param {number} value
 * @param {number} min
 * @param {number} max
 * @returns {number}
 */
export const clamp = (value, min, max) => Math.min(Math.max(value, min), max)

/**
 * Parse a string as a percentage number, returning `fallback` when the value
 * is empty or not a finite number.
 * @param {string | null | undefined} value
 * @param {number} fallback
 * @returns {number}
 */
export const parsePercentage = (value, fallback) => {
  if (value === null || value === undefined || value === "") return fallback
  const parsed = Number.parseFloat(value)
  return Number.isFinite(parsed) ? parsed : fallback
}

/**
 * Normalize an array of percentage values so they sum to 100.
 * If the total is zero or negative, distributes equally.
 * @param {number[]} values
 * @returns {number[]}
 */
export const normalizePercentages = (values) => {
  if (!values.length) return values
  const total = values.reduce((sum, value) => sum + value, 0)
  if (total <= 0) return values.map(() => 100 / values.length)
  return values.map((value) => (value / total) * 100)
}

/**
 * Create highlight helpers for a listbox-style component.
 *
 * Returns an object with:
 * - `highlight(target)` — mark a single item (or `null` to clear all)
 * - `onMouseEnter` / `onMouseLeave` / `onFocus` — event handlers
 * - `bind(items)` / `unbind(items)` — attach/detach listeners on item elements
 *
 * @param {() => HTMLElement[]} getItems - Returns current item elements.
 * @param {() => void} [onAfterHighlight] - Optional callback after highlight changes (e.g. sync ARIA).
 */
export const createItemHighlighter = (getItems, onAfterHighlight) => {
  const highlight = (target) => {
    for (const item of getItems()) {
      item.dataset.highlighted = item === target ? "true" : "false"
    }
    if (onAfterHighlight) onAfterHighlight()
  }

  const onFocus = (event) => highlight(event.currentTarget)
  const onMouseEnter = (event) => highlight(event.currentTarget)
  const onMouseLeave = () => highlight(null)

  const bind = (items) => {
    for (const item of items) {
      item.addEventListener("focus", onFocus)
      item.addEventListener("mouseenter", onMouseEnter)
      item.addEventListener("mouseleave", onMouseLeave)
    }
  }

  const unbind = (items) => {
    for (const item of items) {
      item.removeEventListener("focus", onFocus)
      item.removeEventListener("mouseenter", onMouseEnter)
      item.removeEventListener("mouseleave", onMouseLeave)
    }
  }

  return { highlight, onFocus, onMouseEnter, onMouseLeave, bind, unbind }
}

/**
 * Create a simple typeahead matcher for menu/listbox items.
 *
 * Repeated printable keys within a short window extend the current query.
 *
 * @param {() => HTMLElement[]} getItems
 * @param {(item: HTMLElement) => string} getLabel
 * @param {(item: HTMLElement) => void} onMatch
 */
export const createTypeaheadMatcher = (getItems, getLabel, onMatch) => {
  let buffer = ""
  let resetTimer = null

  const reset = () => {
    buffer = ""
    if (resetTimer) window.clearTimeout(resetTimer)
    resetTimer = null
  }

  const search = (key) => {
    if (key.length !== 1) return false

    buffer = `${buffer}${key.toLowerCase()}`
    if (resetTimer) window.clearTimeout(resetTimer)
    resetTimer = window.setTimeout(reset, 500)

    const items = getItems()
    const match =
      items.find((item) => getLabel(item).toLowerCase().startsWith(buffer)) ||
      items.find((item) => getLabel(item).toLowerCase().startsWith(key.toLowerCase()))

    if (!match) return false
    onMatch(match)
    return true
  }

  return { search, reset }
}
