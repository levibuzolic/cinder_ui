import { FOCUSABLE_SELECTOR } from "./constants.js"

// -----------------------------------------------------------------------------
// MARK: Focus Management
// -----------------------------------------------------------------------------

/**
 * Return all focusable, visible elements inside `root`.
 * @param {HTMLElement | null} root
 * @returns {HTMLElement[]}
 */
export const getFocusableElements = (root) =>
  root ? Array.from(root.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) => !el.hasAttribute("hidden")) : []

/**
 * Focus the first focusable element inside `root`. Falls back to focusing
 * `root` itself if no focusable children exist.
 * @param {HTMLElement | null} root
 * @returns {boolean} Whether an element was focused.
 */
export const focusFirst = (root) => {
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

/**
 * Return the first focusable element inside `root`, or `root` itself.
 * @param {HTMLElement | null} root
 * @returns {HTMLElement | null}
 */
export const getFocusTarget = (root) => getFocusableElements(root)[0] || root || null

/**
 * Restore focus to `preferred` if it is still in the DOM, otherwise fall back
 * to `fallback`.
 * @param {HTMLElement | null} preferred
 * @param {HTMLElement | null} fallback
 */
export const restoreFocus = (preferred, fallback) => {
  if (preferred && document.contains(preferred) && typeof preferred.focus === "function") {
    preferred.focus()
    return
  }

  if (fallback && document.contains(fallback) && typeof fallback.focus === "function") {
    fallback.focus()
  }
}
