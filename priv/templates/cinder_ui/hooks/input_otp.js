// -----------------------------------------------------------------------------
// MARK: Input OTP
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for segmented OTP inputs.
 *
 * Auto-advances on entry, moves back on Backspace from an empty field, and
 * distributes pasted digits across the remaining inputs.
 *
 * **Data attributes:** `data-input-otp-input`, `data-input-otp-index`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiInputOtp = {
  mounted() {
    this.setup()
  },

  updated() {
    this.teardown()
    this.setup()
  },

  setup() {
    this.inputs = Array.from(this.el.querySelectorAll("[data-input-otp-input]"))
    this.cleanups = []

    const focusInput = (index) => {
      const target = this.inputs[index]
      if (!target) return
      target.focus()
      target.select()
    }

    const fillFrom = (startIndex, text) => {
      const chars = Array.from(text.replace(/\D/g, ""))
      if (!chars.length) return

      let index = startIndex
      for (const char of chars) {
        const input = this.inputs[index]
        if (!input) break
        input.value = char
        index += 1
      }

      const nextIndex = Math.min(index, this.inputs.length - 1)
      focusInput(nextIndex)
    }

    this.inputs.forEach((input, index) => {
      const onInput = () => {
        const value = input.value.replace(/\D/g, "")

        if (value.length > 1) {
          fillFrom(index, value)
          return
        }

        input.value = value
        if (value !== "" && index < this.inputs.length - 1) {
          focusInput(index + 1)
        }
      }

      const onKeyDown = (event) => {
        if (event.key === "Backspace" && input.value === "" && index > 0) {
          event.preventDefault()
          const previous = this.inputs[index - 1]
          previous.value = ""
          focusInput(index - 1)
        }

        if (event.key === "ArrowLeft" && index > 0) {
          event.preventDefault()
          focusInput(index - 1)
        }

        if (event.key === "ArrowRight" && index < this.inputs.length - 1) {
          event.preventDefault()
          focusInput(index + 1)
        }
      }

      const onPaste = (event) => {
        event.preventDefault()
        fillFrom(index, event.clipboardData?.getData("text") || "")
      }

      const onFocus = () => input.select()

      input.addEventListener("input", onInput)
      input.addEventListener("keydown", onKeyDown)
      input.addEventListener("paste", onPaste)
      input.addEventListener("focus", onFocus)

      this.cleanups.push(() => {
        input.removeEventListener("input", onInput)
        input.removeEventListener("keydown", onKeyDown)
        input.removeEventListener("paste", onPaste)
        input.removeEventListener("focus", onFocus)
      })
    })
  },

  teardown() {
    if (!this.cleanups) return
    this.cleanups.forEach((cleanup) => cleanup())
    this.cleanups = []
  },

  destroyed() {
    this.teardown()
  },
}
