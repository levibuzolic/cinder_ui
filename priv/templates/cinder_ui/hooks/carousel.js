// -----------------------------------------------------------------------------
// MARK: Carousel
// -----------------------------------------------------------------------------

/**
 * Phoenix LiveView hook for the `carousel` component.
 *
 * Translates a horizontal track by 100% per slide. Wraps around at both ends.
 *
 * **Data attributes:** `data-carousel-track`, `data-slot="carousel-item"`,
 * `data-carousel-prev`, `data-carousel-next`.
 *
 * @type {import("phoenix_live_view").ViewHookInterface}
 */
export const CuiCarousel = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

  destroyed() {
    this.teardown()
  },

  setup() {
    this.teardown()

    this.index = this.index || 0
    this.autoplayInterval = Number.parseInt(this.el.dataset.autoplay || "", 10)
    this.track = this.el.querySelector("[data-carousel-track]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='carousel-item']"))
    this.prev = this.el.querySelector("[data-carousel-prev]")
    this.next = this.el.querySelector("[data-carousel-next]")
    this.indicators = Array.from(this.el.querySelectorAll("[data-slot='carousel-indicator']"))
    this.isHovered = false
    this.cleanups = []

    this.sync = () => {
      if (!this.track || this.items.length === 0) return

      this.index = ((this.index % this.items.length) + this.items.length) % this.items.length
      const percentage = this.index * 100
      this.track.style.transform = `translateX(-${percentage}%)`
      this.track.style.transition = "transform 240ms ease"

      this.items.forEach((item, index) => {
        item.dataset.active = index === this.index ? "true" : "false"
      })

      this.indicators.forEach((indicator, index) => {
        indicator.dataset.active = index === this.index ? "true" : "false"
        indicator.setAttribute("aria-current", index === this.index ? "true" : "false")
      })
    }

    this.goTo = (index) => {
      if (!Number.isInteger(index)) return
      this.index = index
      this.sync()
    }

    this.onPrev = () => this.goTo(this.index === 0 ? this.items.length - 1 : this.index - 1)
    this.onNext = () => this.goTo(this.index === this.items.length - 1 ? 0 : this.index + 1)
    this.onMouseEnter = () => {
      this.isHovered = true
      this.stopAutoplay()
    }
    this.onMouseLeave = () => {
      this.isHovered = false
      this.startAutoplay()
    }

    this.startAutoplay = () => {
      this.stopAutoplay()
      if (!Number.isFinite(this.autoplayInterval) || this.autoplayInterval <= 0 || this.items.length <= 1 || this.isHovered) return

      this.autoplayTimer = window.setInterval(() => this.onNext(), this.autoplayInterval)
    }

    this.stopAutoplay = () => {
      if (this.autoplayTimer) {
        window.clearInterval(this.autoplayTimer)
        this.autoplayTimer = null
      }
    }

    this.prev && this.prev.addEventListener("click", this.onPrev)
    this.next && this.next.addEventListener("click", this.onNext)
    this.el.addEventListener("mouseenter", this.onMouseEnter)
    this.el.addEventListener("mouseleave", this.onMouseLeave)
    this.indicators.forEach((indicator) => {
      const onClick = () => this.goTo(Number(indicator.dataset.carouselIndicator))
      indicator.addEventListener("click", onClick)
      this.cleanups.push(() => indicator.removeEventListener("click", onClick))
    })

    this.sync()
    this.startAutoplay()
  },

  teardown() {
    this.stopAutoplay && this.stopAutoplay()
    this.prev && this.onPrev && this.prev.removeEventListener("click", this.onPrev)
    this.next && this.onNext && this.next.removeEventListener("click", this.onNext)
    this.el.removeEventListener("mouseenter", this.onMouseEnter)
    this.el.removeEventListener("mouseleave", this.onMouseLeave)
    if (this.cleanups) this.cleanups.forEach((cleanup) => cleanup())
    this.cleanups = []
  },
}
