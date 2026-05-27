// -----------------------------------------------------------------------------
// MARK: Inert Management
// -----------------------------------------------------------------------------

/**
 * Apply the `inert` attribute to all sibling branches of `overlayEl` up to
 * `document.body`, effectively trapping interaction inside the overlay.
 *
 * @param {HTMLElement} overlayEl
 * @returns {HTMLElement[]} Elements that were marked inert (for later cleanup).
 */
export const applyInert = (overlayEl) => {
  const inertedElements = []
  let current = overlayEl

  while (current && current !== document.body) {
    const parent = current.parentElement
    if (parent) {
      for (const sibling of parent.children) {
        if (sibling !== current && !sibling.inert) {
          sibling.inert = true
          inertedElements.push(sibling)
        }
      }
    }
    current = parent
  }

  return inertedElements
}

/**
 * Remove the `inert` attribute from elements previously marked by
 * {@link applyInert}.
 * @param {HTMLElement[] | null} inertedElements
 */
export const removeInert = (inertedElements) => {
  if (!inertedElements) return
  for (const el of inertedElements) {
    el.inert = false
  }
}
