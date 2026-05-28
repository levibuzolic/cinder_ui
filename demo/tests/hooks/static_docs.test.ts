import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

declare global {
  // eslint-disable-next-line no-var
  var __CUI_DISABLE_STATIC_DOCS_AUTO_INIT: boolean | undefined
  // eslint-disable-next-line no-var
  var CinderUIThemeModel: unknown
  // eslint-disable-next-line no-var
  var CinderUITheme: unknown
  // eslint-disable-next-line no-var
  var __cuiThemeSystemWatcher: unknown
  // eslint-disable-next-line no-var
  var __cuiThemeStorageWatcher: unknown
}

const loadStaticDocsModule = async () => {
  vi.resetModules()
  globalThis.__CUI_DISABLE_STATIC_DOCS_AUTO_INIT = true
  const { readFileSync } = await import("node:fs")
  globalThis.CinderUIThemeModel = JSON.parse(
    readFileSync("../dev/assets/docs/theme_model.json", "utf8"),
  )
  // @ts-expect-error theme_bootstrap.js is plain JS without published types.
  await import("../../../priv/site_templates/theme_bootstrap.js")
  // @ts-expect-error static_docs.js is plain JS without published types.
  return import("../../../dev/assets/docs/static_docs.js")
}

beforeEach(() => {
  document.body.innerHTML = ""
  window.localStorage.clear()
  delete (window as Window & { liveSocket?: unknown }).liveSocket
  Object.defineProperty(window, "matchMedia", {
    writable: true,
    value: vi.fn().mockImplementation(() => ({
      matches: false,
      media: "(prefers-color-scheme: dark)",
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
})

afterEach(() => {
  vi.restoreAllMocks()
  delete globalThis.__CUI_DISABLE_STATIC_DOCS_AUTO_INIT
  delete globalThis.CinderUIThemeModel
  delete globalThis.CinderUITheme
  delete globalThis.__cuiThemeSystemWatcher
  delete globalThis.__cuiThemeStorageWatcher
  delete (window as Window & {
    CinderUIStaticHookNames?: string[]
    CinderUIStaticUsedHooks?: string[]
    CinderUIStaticMissingHooks?: string[]
    liveSocket?: unknown
  }).CinderUIStaticHookNames
  delete (window as Window & {
    CinderUIStaticHookNames?: string[]
    CinderUIStaticUsedHooks?: string[]
    CinderUIStaticMissingHooks?: string[]
    liveSocket?: unknown
  }).CinderUIStaticUsedHooks
  delete (window as Window & {
    CinderUIStaticHookNames?: string[]
    CinderUIStaticUsedHooks?: string[]
    CinderUIStaticMissingHooks?: string[]
    liveSocket?: unknown
  }).CinderUIStaticMissingHooks
})

describe("static docs hook adapter", () => {
  it("applies the resolved theme to root data attributes on first load", async () => {
    Object.defineProperty(window, "matchMedia", {
      writable: true,
      value: vi.fn().mockImplementation(() => ({
        matches: true,
        media: "(prefers-color-scheme: dark)",
        onchange: null,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })),
    })

    window.localStorage.setItem("cui:theme:mode", "auto")

    await loadStaticDocsModule()

    expect(document.documentElement.classList.contains("dark")).toBe(true)
    expect(document.documentElement.dataset.theme).toBe("dark")
    expect(document.documentElement.dataset.themeMode).toBe("auto")
    expect(document.documentElement.dataset.themeColor).toBe("neutral")
    expect(document.documentElement.dataset.themeRadius).toBe("nova")
    expect(document.documentElement.style.getPropertyValue("--background")).toBe("oklch(0.145 0 0)")
  })

  it("restores stored palette and radius tokens onto the root element", async () => {
    window.localStorage.setItem("cui:theme:mode", "dark")
    window.localStorage.setItem("cui:theme:color", "zinc")
    window.localStorage.setItem("cui:theme:radius", "vega")

    await loadStaticDocsModule()

    expect(document.documentElement.dataset.theme).toBe("dark")
    expect(document.documentElement.dataset.themeMode).toBe("dark")
    expect(document.documentElement.dataset.themeColor).toBe("zinc")
    expect(document.documentElement.dataset.themeRadius).toBe("vega")
    expect(document.documentElement.style.getPropertyValue("--sidebar")).toBe("oklch(0.141 0.005 285.823)")
    expect(document.documentElement.style.getPropertyValue("--radius")).toBe("1rem")
  })

  it("records missing hook names used in static markup", async () => {
    document.body.innerHTML = `
      <div phx-hook="CuiSelect"></div>
      <div phx-hook="CuiMissingThing"></div>
    `

    const { initializeStaticHooks } = await loadStaticDocsModule()

    initializeStaticHooks()

    expect(window.CinderUIStaticUsedHooks).toEqual(["CuiSelect", "CuiMissingThing"])
    expect(window.CinderUIStaticMissingHooks).toEqual(["CuiMissingThing"])
    expect(window.CinderUIStaticHookNames).toContain("CuiSelect")
  })

  it("does not mount static hooks when a liveSocket is present", async () => {
    document.body.innerHTML = `
      <div data-slot="sidebar-layout" data-state="expanded" data-collapsible="icon" phx-hook="CuiSidebar">
        <button data-sidebar-trigger aria-expanded="true"></button>
      </div>
    `

    ;(window as Window & { liveSocket?: { connect: () => void } }).liveSocket = {
      connect: () => {},
    }

    const { initializeStaticHooks } = await loadStaticDocsModule()

    initializeStaticHooks()

    const el = document.querySelector("[phx-hook='CuiSidebar']") as HTMLElement & {
      __cuiStaticHook?: unknown
    }

    expect(el.__cuiStaticHook).toBeUndefined()
    expect(window.CinderUIStaticUsedHooks).toBeUndefined()
  })

  it("mounts the real sidebar hook onto static markup", async () => {
    document.body.innerHTML = `
      <div
        id="static-sidebar"
        data-slot="sidebar-layout"
        data-state="expanded"
        data-collapsible="icon"
        phx-hook="CuiSidebar"
      >
        <button data-sidebar-trigger aria-expanded="true"></button>
        <span data-sidebar-label>Overview</span>
      </div>
    `

    const { initializeStaticHooks } = await loadStaticDocsModule()

    initializeStaticHooks()

    const root = document.querySelector("#static-sidebar") as HTMLElement & {
      __cuiStaticHook?: { toggle?: () => void }
    }
    const trigger = root.querySelector("[data-sidebar-trigger]") as HTMLButtonElement

    expect(root.__cuiStaticHook).toBeDefined()
    expect(root.dataset.state).toBe("expanded")
    expect(trigger.getAttribute("aria-expanded")).toBe("true")

    trigger.click()

    expect(root.dataset.state).toBe("collapsed")
    expect(trigger.getAttribute("aria-expanded")).toBe("false")
  })

  it("mounts the real select hook and updates the hidden value", async () => {
    document.body.innerHTML = `
      <div data-slot="select" data-state="closed" data-placeholder="Choose a plan" phx-hook="CuiSelect">
        <input data-slot="select-input" type="hidden" value="" />
        <button type="button" data-select-trigger aria-expanded="false">
          <span data-slot="select-value">Choose a plan</span>
        </button>
        <button type="button" data-select-clear class="hidden">Clear</button>
        <div data-select-content class="hidden">
          <button id="plan-free" type="button" data-select-item data-value="free" data-label="Free">
            <span data-slot="select-check" class="hidden"></span>
          </button>
          <button id="plan-pro" type="button" data-select-item data-value="pro" data-label="Pro">
            <span data-slot="select-check" class="hidden"></span>
          </button>
        </div>
      </div>
    `

    const { initializeStaticHooks } = await loadStaticDocsModule()

    initializeStaticHooks()

    const root = document.querySelector("[phx-hook='CuiSelect']") as HTMLElement
    const trigger = root.querySelector("[data-select-trigger]") as HTMLButtonElement
    const input = root.querySelector("[data-slot='select-input']") as HTMLInputElement
    const value = root.querySelector("[data-slot='select-value']") as HTMLElement
    const content = root.querySelector("[data-select-content]") as HTMLElement

    trigger.click()
    expect(content.classList.contains("hidden")).toBe(false)

    ;(root.querySelector("#plan-pro") as HTMLButtonElement).click()

    expect(input.value).toBe("pro")
    expect(value.textContent).toBe("Pro")
    expect(content.classList.contains("hidden")).toBe(true)
  })
})
