// -----------------------------------------------------------------------------
// MARK: Code Block
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for code blocks with copy-to-clipboard support.
 *
 * **Data attributes:** `data-code-block-copy`, `data-code-block-content`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiCodeBlock = {
  mounted() {
    this.refreshElements = () => {
      this.button = this.el.querySelector("[data-code-block-copy]")
      this.label = this.el.querySelector("[data-code-block-copy-label]")
      this.content = this.el.querySelector("[data-code-block-content]")
    }

    this.resetLabel = null
    this.setLabel = (text) => {
      if (this.label) this.label.textContent = text
    }

    this.onClick = async (event) => {
      event.preventDefault()
      const text = this.content?.textContent || ""
      if (!text) return

      try {
        await navigator.clipboard.writeText(text)
        this.setLabel("Copied")
      } catch {
        this.setLabel("Failed")
      }

      if (this.resetLabel) window.clearTimeout(this.resetLabel)
      this.resetLabel = window.setTimeout(() => this.setLabel("Copy"), 1500)
    }

    this.refreshElements()
    this.button?.addEventListener("click", this.onClick)
  },

  updated() {
    this.button?.removeEventListener("click", this.onClick)
    this.refreshElements()
    this.button?.addEventListener("click", this.onClick)
  },

  destroyed() {
    if (this.resetLabel) window.clearTimeout(this.resetLabel)
    this.button?.removeEventListener("click", this.onClick)
  },
}
