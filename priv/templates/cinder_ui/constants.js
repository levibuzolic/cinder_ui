// -----------------------------------------------------------------------------
// MARK: Constants
// -----------------------------------------------------------------------------

/** Custom event name used for imperative component commands. */
export const COMMAND_EVENT = "cinder-ui:command"

/** Selector matching all natively focusable, non-disabled elements. */
export const FOCUSABLE_SELECTOR =
  "button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])"
