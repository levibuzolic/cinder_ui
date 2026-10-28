import { expect, it, vi } from "vitest"

// @ts-expect-error The library hook sources are plain JavaScript.
import { CinderUIHooks } from "../../../priv/templates/cinder_ui/index.js"
// @ts-expect-error The docs fixture is plain JavaScript.
import { withAutocompleteSearchDemo } from "../../../dev/assets/docs/autocomplete_search_demo.js"

it("ignores superseded demo queries and cancels pending work when destroyed", () => {
  vi.useFakeTimers()
  document.body.innerHTML = `
    <div id="owner-search" data-filter="false">
      <input data-autocomplete-input />
      <div data-autocomplete-content>
        <div data-autocomplete-group>
          <button data-autocomplete-item data-value="levi" data-label="Levi Buzolic">Levi</button>
          <button data-autocomplete-item data-value="mira" data-label="Mira Chen">Mira</button>
          <button data-autocomplete-item data-value="sam" data-label="Sam Hall">Sam</button>
        </div>
        <div data-slot="autocomplete-empty" class="hidden">No results found.</div>
      </div>
    </div>`
  const el = document.body.firstElementChild as HTMLElement
  const hook = { ...withAutocompleteSearchDemo(CinderUIHooks.CuiAutocomplete), el }
  hook.mounted()
  const input = el.querySelector<HTMLInputElement>("[data-autocomplete-input]")!
  const type = (query: string) => {
    input.value = query
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }
  try {
    type("designer")
    vi.advanceTimersByTime(400)
    type("ops")
    vi.advanceTimersByTime(400)
    expect(el.querySelectorAll("[data-autocomplete-item]:not(.hidden)")).toHaveLength(0)
    vi.advanceTimersByTime(400)
    expect(el.querySelector<HTMLElement>("[data-autocomplete-item]:not(.hidden)")?.dataset.value).toBe("sam")
    type("engineer")
  } finally {
    hook.destroyed()
    vi.advanceTimersByTime(1000)
    expect(vi.getTimerCount()).toBe(0)
    vi.useRealTimers()
    document.body.innerHTML = ""
  }
})
