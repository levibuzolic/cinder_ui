import { COMMAND_EVENT } from "./constants.js"

// -----------------------------------------------------------------------------
// MARK: Command System
// -----------------------------------------------------------------------------

/**
 * Register a listener for {@link COMMAND_EVENT} on `root`.
 *
 * Commands are dispatched as `CustomEvent` instances whose `detail.command`
 * string is looked up in the `handlers` map.
 *
 * @param {HTMLElement} root - Element to listen on (events do not bubble).
 * @param {Record<string, (detail: object) => void>} handlers
 * @returns {() => void} Cleanup function that removes the listener.
 */
export const registerCommandListener = (root, handlers) => {
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

/**
 * Dispatch a command to a component's root element.
 *
 * @example
 * ```js
 * CinderUI.dispatchCommand(selectEl, "open")
 * CinderUI.dispatchCommand(dialogEl, "close")
 * ```
 *
 * @param {HTMLElement | null} target
 * @param {string} command
 * @param {object} [detail={}]
 */
export const dispatchCommand = (target, command, detail = {}) => {
  if (!target) return
  target.dispatchEvent(
    new CustomEvent(COMMAND_EVENT, {
      bubbles: false,
      detail: { ...detail, command },
    }),
  )
}
