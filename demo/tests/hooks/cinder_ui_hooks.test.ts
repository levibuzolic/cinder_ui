import { afterEach, describe, expect, it, vi } from "vitest"

// @ts-expect-error priv/templates/cinder_ui.js is plain JS without published types.
import { CinderUI, CinderUIHooks } from "../../../priv/templates/cinder_ui.js"

type HookName = keyof typeof CinderUIHooks
type HookInstance = {
  el: HTMLElement
  mounted?: () => void
  updated?: () => void
  destroyed?: () => void
}

const mountHook = <T extends HookName>(name: T, html: string) => {
  document.body.innerHTML = html.trim()
  const el = document.body.firstElementChild as HTMLElement
  const hook = { ...CinderUIHooks[name], el } as HookInstance
  hook.mounted?.()
  return { el, hook }
}

afterEach(() => {
  vi.useRealTimers()
  vi.restoreAllMocks()
  window.localStorage.clear()
  document.body.innerHTML = ""
})

describe("Cinder UI hook harness", () => {
  it("select supports typeahead and clear commands", () => {
    const { el } = mountHook(
      "CuiSelect",
      `
        <div data-slot="select" data-state="closed" data-placeholder="Choose a plan">
          <input data-slot="select-input" type="hidden" value="pro" />
          <button type="button" data-select-trigger aria-expanded="false">
            <span data-slot="select-value">Pro</span>
          </button>
          <button type="button" data-select-clear>Clear</button>
          <div data-select-content class="hidden">
            <button id="plan-free" type="button" data-select-item data-value="free" data-label="Free">
              <span data-slot="select-check" class="hidden"></span>
            </button>
            <button
              id="plan-pro"
              type="button"
              data-select-item
              data-value="pro"
              data-label="Pro"
              data-selected="true"
              aria-selected="true"
            >
              <span data-slot="select-check"></span>
            </button>
            <button id="plan-team" type="button" data-select-item data-value="team" data-label="Team">
              <span data-slot="select-check" class="hidden"></span>
            </button>
          </div>
        </div>
      `,
    )

    const trigger = el.querySelector("[data-select-trigger]") as HTMLButtonElement
    const content = el.querySelector("[data-select-content]") as HTMLElement
    const input = el.querySelector("[data-slot='select-input']") as HTMLInputElement
    const value = el.querySelector("[data-slot='select-value']") as HTMLElement
    const clearButton = el.querySelector("[data-select-clear]") as HTMLButtonElement
    const team = el.querySelector("#plan-team") as HTMLButtonElement

    trigger.dispatchEvent(new KeyboardEvent("keydown", { key: "T", bubbles: true }))

    expect(content.dataset.state).toBe("open")
    expect(document.activeElement).toBe(team)
    expect(trigger.getAttribute("aria-activedescendant")).toBe("plan-team")

    CinderUI.dispatchCommand(el, "clear")

    expect(input.value).toBe("")
    expect(value.textContent).toBe("Choose a plan")
    expect(clearButton.classList.contains("hidden")).toBe(true)
  })

  it("autocomplete filters visible items and selects from keyboard navigation", () => {
    const { el } = mountHook(
      "CuiAutocomplete",
      `
        <div data-slot="autocomplete" data-state="closed" data-selected-label="Levi Buzolic">
          <input data-slot="autocomplete-value" type="hidden" value="levi" />
          <input
            data-autocomplete-input
            value="Levi Buzolic"
            aria-expanded="false"
            aria-activedescendant=""
          />
          <div data-autocomplete-content class="hidden">
            <button id="owner-levi" type="button" data-autocomplete-item data-value="levi" data-label="Levi Buzolic">
              Levi
              <span data-slot="select-check"></span>
            </button>
            <button id="owner-mira" type="button" data-autocomplete-item data-value="mira" data-label="Mira Chen">
              Mira
              <span data-slot="select-check" class="hidden"></span>
            </button>
            <button id="owner-sam" type="button" data-autocomplete-item data-value="sam" data-label="Sam Hall">
              Sam
              <span data-slot="select-check" class="hidden"></span>
            </button>
            <div data-slot="autocomplete-empty" class="hidden">No matches</div>
          </div>
        </div>
      `,
    )

    const input = el.querySelector("[data-autocomplete-input]") as HTMLInputElement
    const hiddenInput = el.querySelector("[data-slot='autocomplete-value']") as HTMLInputElement
    const content = el.querySelector("[data-autocomplete-content]") as HTMLElement
    const levi = el.querySelector("#owner-levi") as HTMLButtonElement
    const sam = el.querySelector("#owner-sam") as HTMLButtonElement

    input.value = "a"
    input.dispatchEvent(new Event("input", { bubbles: true }))

    expect(content.dataset.state).toBe("open")
    expect(levi.classList.contains("hidden")).toBe(true)
    expect(hiddenInput.value).toBe("")

    input.dispatchEvent(new KeyboardEvent("keydown", { key: "End", bubbles: true }))
    expect(document.activeElement).toBe(sam)
    expect(sam.dataset.highlighted).toBe("true")

    input.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }))

    expect(input.value).toBe("Sam Hall")
    expect(hiddenInput.value).toBe("sam")
    expect(content.classList.contains("hidden")).toBe(true)
  })

  it("input otp distributes pasted digits across remaining cells", () => {
    const { el } = mountHook(
      "CuiInputOtp",
      `
        <div data-slot="input-otp">
          <input data-input-otp-input data-input-otp-index="0" />
          <input data-input-otp-input data-input-otp-index="1" />
          <input data-input-otp-input data-input-otp-index="2" />
          <input data-input-otp-input data-input-otp-index="3" />
        </div>
      `,
    )

    const inputs = Array.from(el.querySelectorAll("[data-input-otp-input]")) as HTMLInputElement[]
    const pasteEvent = new Event("paste", { bubbles: true, cancelable: true })
    Object.defineProperty(pasteEvent, "clipboardData", {
      value: { getData: () => "12a34" },
    })

    inputs[0].dispatchEvent(pasteEvent)

    expect(inputs.map((input) => input.value)).toEqual(["1", "2", "3", "4"])
    expect(document.activeElement).toBe(inputs[3])
  })

  it("menubar supports keyboard open, lateral navigation, and escape", () => {
    const { el } = mountHook(
      "CuiMenubar",
      `
        <div data-slot="menubar">
          <div data-slot="menubar-menu">
            <button type="button" data-menubar-trigger aria-expanded="false">File</button>
            <div data-menubar-content class="hidden">
              <button type="button">New project</button>
            </div>
          </div>
          <div data-slot="menubar-menu">
            <button type="button" data-menubar-trigger aria-expanded="false">View</button>
            <div data-menubar-content class="hidden">
              <button type="button">Toggle sidebar</button>
            </div>
          </div>
        </div>
      `,
    )

    const triggers = Array.from(el.querySelectorAll("[data-menubar-trigger]")) as HTMLButtonElement[]
    const contents = Array.from(el.querySelectorAll("[data-menubar-content]")) as HTMLElement[]
    const firstMenuItem = contents[0].querySelector("button") as HTMLButtonElement

    triggers[0].focus()
    triggers[0].dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true }))

    expect(contents[0].dataset.state).toBe("open")
    expect(triggers[0].getAttribute("aria-expanded")).toBe("true")
    expect(document.activeElement).toBe(firstMenuItem)

    firstMenuItem.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }))

    expect(document.activeElement).toBe(triggers[1])
    expect(contents[1].dataset.state).toBe("open")

    triggers[1].dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }))

    expect(contents[0].classList.contains("hidden")).toBe(true)
    expect(contents[1].classList.contains("hidden")).toBe(true)
    expect(document.activeElement).toBe(triggers[1])
  })

  it("carousel advances with autoplay, pauses on hover, and syncs indicators", () => {
    vi.useFakeTimers()

    const { el } = mountHook(
      "CuiCarousel",
      `
        <div data-slot="carousel" data-autoplay="1000">
          <div data-carousel-track>
            <div data-slot="carousel-item"></div>
            <div data-slot="carousel-item"></div>
            <div data-slot="carousel-item"></div>
          </div>
          <button type="button" data-carousel-prev></button>
          <button type="button" data-carousel-next></button>
          <button type="button" data-slot="carousel-indicator" data-carousel-indicator="0"></button>
          <button type="button" data-slot="carousel-indicator" data-carousel-indicator="1"></button>
          <button type="button" data-slot="carousel-indicator" data-carousel-indicator="2"></button>
        </div>
      `,
    )

    const track = el.querySelector("[data-carousel-track]") as HTMLElement
    const indicators = Array.from(el.querySelectorAll("[data-slot='carousel-indicator']")) as HTMLButtonElement[]

    expect(track.style.transform).toBe("translateX(-0%)")
    expect(indicators[0].getAttribute("aria-current")).toBe("true")

    vi.advanceTimersByTime(1000)

    expect(track.style.transform).toBe("translateX(-100%)")
    expect(indicators[1].dataset.active).toBe("true")

    el.dispatchEvent(new Event("mouseenter", { bubbles: true }))
    vi.advanceTimersByTime(3000)
    expect(track.style.transform).toBe("translateX(-100%)")

    indicators[2].click()
    expect(track.style.transform).toBe("translateX(-200%)")
    expect(indicators[2].getAttribute("aria-current")).toBe("true")
  })

  it("resizable restores saved sizes and persists keyboard adjustments", () => {
    window.localStorage.setItem("docs-layout", JSON.stringify([60, 40]))

    const { el } = mountHook(
      "CuiResizable",
      `
        <div data-direction="horizontal" data-storage-key="docs-layout">
          <div data-slot="resizable-panel" data-min-size="20"></div>
          <div data-slot="resizable-handle" tabindex="0"></div>
          <div data-slot="resizable-panel" data-min-size="20"></div>
        </div>
      `,
    )

    const panels = Array.from(el.querySelectorAll("[data-slot='resizable-panel']")) as HTMLElement[]
    const handle = el.querySelector("[data-slot='resizable-handle']") as HTMLElement

    expect(panels[0].dataset.size).toBe("60")
    expect(panels[1].dataset.size).toBe("40")

    handle.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowLeft", shiftKey: true, bubbles: true }))

    expect(panels[0].dataset.size).toBe("50")
    expect(panels[1].dataset.size).toBe("50")
    expect(window.localStorage.getItem("docs-layout")).toBe("[50,50]")
  })
})
