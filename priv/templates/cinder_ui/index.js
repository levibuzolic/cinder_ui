import { dispatchCommand } from "./commands.js"
import { CuiDialog } from "./hooks/dialog.js"
import { CuiDrawer, CuiSheet } from "./hooks/panels.js"
import { CuiPopover } from "./hooks/popover.js"
import { CuiDropdownMenu } from "./hooks/dropdown_menu.js"
import { CuiMenubar } from "./hooks/menubar.js"
import { CuiSelect } from "./hooks/select.js"
import { CuiAutocomplete } from "./hooks/autocomplete.js"
import { CuiInputOtp } from "./hooks/input_otp.js"
import { CuiCodeBlock } from "./hooks/code_block.js"
import { CuiCombobox } from "./hooks/combobox.js"
import { CuiSidebar } from "./hooks/sidebar.js"
import { CuiCarousel } from "./hooks/carousel.js"
import { CuiResizable } from "./hooks/resizable.js"

// -----------------------------------------------------------------------------
// MARK: Exports
// -----------------------------------------------------------------------------

/**
 * All CinderUI Phoenix LiveView hooks. Register these with your LiveSocket:
 *
 * ```js
 * import { CinderUIHooks } from "./cinder_ui"
 * const liveSocket = new LiveSocket("/live", Socket, {
 *   hooks: { ...CinderUIHooks },
 * })
 * ```
 */
export const CinderUIHooks = {
  CuiDialog,
  CuiDrawer,
  CuiSheet,
  CuiPopover,
  CuiDropdownMenu,
  CuiMenubar,
  CuiSelect,
  CuiAutocomplete,
  CuiInputOtp,
  CuiCodeBlock,
  CuiCombobox,
  CuiSidebar,
  CuiCarousel,
  CuiResizable,
}

/**
 * Public API for imperative component control from outside LiveView hooks.
 *
 * ```js
 * import { CinderUI } from "./cinder_ui"
 * CinderUI.dispatchCommand(document.getElementById("my-dialog"), "open")
 * ```
 */
export const CinderUI = {
  dispatchCommand,
}
