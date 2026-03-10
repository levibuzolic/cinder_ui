import { expect, test } from "@playwright/test"

const hasClass = async (
  locator: { evaluate: (fn: (el: Element, cls: string) => boolean, cls: string) => Promise<boolean> },
  className: string,
) => locator.evaluate((el: Element, cls: string) => el.classList.contains(cls), className)

test.describe("interactive previews", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/docs/")
  })

  test("dialog opens and closes", async ({ page }) => {
    const root = page.locator("[data-slot='dialog']").first()
    const trigger = root.locator("[data-dialog-trigger]")
    const content = root.locator("[data-dialog-content]")
    const close = root.locator("[data-dialog-close]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await trigger.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await page.keyboard.press("Escape")
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("command events control dialog and select consistently", async ({ page }) => {
    const dialog = page.locator("[data-slot='dialog']").first()
    const dialogContent = dialog.locator("[data-dialog-content]")
    const select = page.locator("[data-slot='select']").first()
    const selectContent = select.locator("[data-select-content]")

    await dialog.scrollIntoViewIfNeeded()
    await page.evaluate(() => {
      const dispatch = (selector: string, command: string) => {
        const target = document.querySelector(selector)
        target?.dispatchEvent(
          new CustomEvent("cinder-ui:command", {
            bubbles: false,
            detail: { command },
          }),
        )
      }

      dispatch("[data-slot='dialog']", "open")
      dispatch("[data-slot='select']", "open")
    })

    expect(await hasClass(dialogContent, "hidden")).toBe(false)
    expect(await hasClass(selectContent, "hidden")).toBe(false)

    await page.evaluate(() => {
      const dispatch = (selector: string, command: string) => {
        const target = document.querySelector(selector)
        target?.dispatchEvent(
          new CustomEvent("cinder-ui:command", {
            bubbles: false,
            detail: { command },
          }),
        )
      }

      dispatch("[data-slot='dialog']", "close")
      dispatch("[data-slot='select']", "close")
    })

    expect(await hasClass(dialogContent, "hidden")).toBe(true)
    expect(await hasClass(selectContent, "hidden")).toBe(true)
  })

  test("drawer opens and closes via overlay", async ({ page }) => {
    const root = page.locator("[data-slot='drawer']").first()
    const trigger = root.locator("[data-drawer-trigger]")
    const content = root.locator("[data-drawer-content]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await trigger.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await page.keyboard.press("Escape")
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("sheet opens and closes via escape", async ({ page }) => {
    const root = page.locator("[data-slot='sheet']").first()
    const trigger = root.locator("[data-sheet-trigger]")
    const content = root.locator("[data-sheet-content]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await trigger.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await page.keyboard.press("Escape")
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("popover and dropdown toggle", async ({ page }) => {
    const popover = page.locator("[data-slot='popover']").first()
    const popoverTrigger = popover.locator("[data-popover-trigger]")
    const popoverContent = popover.locator("[data-popover-content]")

    await popover.scrollIntoViewIfNeeded()
    expect(await hasClass(popoverContent, "hidden")).toBe(true)
    await popoverTrigger.click()
    expect(await hasClass(popoverContent, "hidden")).toBe(false)
    await page.keyboard.press("Escape")
    expect(await hasClass(popoverContent, "hidden")).toBe(true)

    const dropdown = page.locator("[data-slot='dropdown-menu']").first()
    const dropdownTrigger = dropdown.locator("[data-dropdown-trigger]")
    const dropdownContent = dropdown.locator("[data-dropdown-content]")

    await dropdown.scrollIntoViewIfNeeded()
    expect(await hasClass(dropdownContent, "hidden")).toBe(true)
    await dropdownTrigger.click()
    expect(await hasClass(dropdownContent, "hidden")).toBe(false)
    await page.keyboard.press("Escape")
    expect(await hasClass(dropdownContent, "hidden")).toBe(true)
  })

  test("interactive hooks remain usable after the docs page re-renders", async ({ page }) => {
    const dialog = page.locator("[data-slot='dialog']").first()
    const select = page.locator("[data-slot='select']").filter({ has: page.locator("[data-slot='select-input'][name='plan']") }).first()
    const autocomplete = page.locator("[data-slot='autocomplete']").first()

    await page.locator(".theme-mode-btn[data-theme-mode='dark']").first().click()

    await dialog.locator("[data-dialog-trigger]").click()
    expect(await hasClass(dialog.locator("[data-dialog-content]"), "hidden")).toBe(false)
    await page.keyboard.press("Escape")
    expect(await hasClass(dialog.locator("[data-dialog-content]"), "hidden")).toBe(true)

    await select.locator("[data-select-trigger]").click()
    expect(await hasClass(select.locator("[data-select-content]"), "hidden")).toBe(false)
    await select.locator("[data-select-item]").last().click()
    await expect(select.locator("[data-slot='select-input']")).not.toHaveValue("")

    await autocomplete.locator("[data-autocomplete-input]").fill("Mira")
    await autocomplete.locator("[data-slot='autocomplete-item'][data-value='mira']").click()
    await expect(autocomplete.locator("[data-slot='autocomplete-value']")).toHaveValue("mira")
  })

  test("select opens from the keyboard and updates the hidden value", async ({ page }) => {
    const select = page.locator("#docs-select")
    const trigger = select.locator("[data-select-trigger]")
    const content = select.locator("[data-select-content]")
    const hiddenInput = select.locator("[data-slot='select-input']")

    await select.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    const initialValue = (await hiddenInput.inputValue()) ?? ""

    await trigger.focus()
    await page.keyboard.press("ArrowDown")
    expect(await hasClass(content, "hidden")).toBe(false)
    const highlightedSelectItem = select.locator("[data-select-item][data-highlighted='true']").first()
    await expect(highlightedSelectItem).toBeVisible()
    await expect(trigger).toHaveAttribute("aria-activedescendant", await highlightedSelectItem.getAttribute("id"))

    const itemStates = await select.locator("[data-select-item]").evaluateAll((els) =>
      els.map((el) => ({
        selected: el.getAttribute("data-selected") === "true",
        disabled: el.getAttribute("data-disabled") === "true",
      })),
    )

    const enabledIndexes = itemStates.flatMap((item, index) => (item.disabled ? [] : [index]))
    const selectedIndex = itemStates.findIndex((item) => item.selected)
    const nextEnabledIndex = enabledIndexes.find((index) => index > selectedIndex)

    const targetIndex =
      nextEnabledIndex !== undefined
        ? nextEnabledIndex
        : enabledIndexes.find((index) => index < selectedIndex) ?? enabledIndexes[0]

    await select.locator("[data-select-item]").nth(targetIndex).click()

    await expect(hiddenInput).not.toHaveValue(initialValue)
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("select clear button resets the hidden value", async ({ page }) => {
    const select = page.locator("[data-slot='select']").filter({ has: page.locator("[data-slot='select-input'][name='plan']") }).first()
    const hiddenInput = select.locator("[data-slot='select-input']")

    await select.scrollIntoViewIfNeeded()
    await expect(hiddenInput).not.toHaveValue("")

    await page.evaluate(() => {
      const target = document.querySelector("[data-slot='select']:has([data-slot='select-input'][name='plan'])")
      target?.dispatchEvent(
        new CustomEvent("cinder-ui:command", {
          bubbles: false,
          detail: { command: "clear" },
        }),
      )
    })

    await expect(hiddenInput).toHaveValue("")
  })

  test("combobox filters and selects", async ({ page }) => {
    const combo = page.locator("[data-slot='combobox']").first()
    const input = combo.locator("[data-combobox-input]")
    const content = combo.locator("[data-combobox-content]")

    await combo.scrollIntoViewIfNeeded()
    await input.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await input.fill("Fr")
    const itemStates = await combo.locator("[data-slot='combobox-item']").evaluateAll((els) =>
      els.map((el) => ({
        text: (el.textContent || "").trim(),
        hidden: el.classList.contains("hidden"),
      })),
    )

    const free = itemStates.find((item) => item.text === "Free")
    const pro = itemStates.find((item) => item.text === "Pro")

    expect(free?.hidden).toBe(false)
    expect(pro?.hidden).toBe(true)

    await combo.locator("[data-slot='combobox-item'][data-value='Free']").click()
    await expect(input).toHaveValue("Free")
  })

  test("autocomplete filters and updates the hidden value", async ({ page }) => {
    const autocomplete = page.locator("#docs-autocomplete")
    const input = autocomplete.locator("[data-autocomplete-input]")
    const content = autocomplete.locator("[data-autocomplete-content]")
    const hiddenInput = autocomplete.locator("[data-slot='autocomplete-value']")

    await autocomplete.scrollIntoViewIfNeeded()
    await input.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await input.fill("Mira")
    await page.keyboard.press("ArrowDown")
    const highlightedAutocompleteItem = autocomplete.locator("[data-slot='autocomplete-item'][data-highlighted='true']").first()
    await expect(highlightedAutocompleteItem).toBeVisible()
    await expect(input).toHaveAttribute("aria-activedescendant", await highlightedAutocompleteItem.getAttribute("id"))
    const itemStates = await autocomplete.locator("[data-slot='autocomplete-item']").evaluateAll((els) =>
      els.map((el) => ({
        text: el.getAttribute("data-label") || (el.textContent || "").trim(),
        hidden: el.classList.contains("hidden"),
      })),
    )

    const levi = itemStates.find((item) => item.text.includes("Levi"))
    const mira = itemStates.find((item) => item.text.includes("Mira"))

    expect(levi?.hidden).toBe(true)
    expect(mira?.hidden).toBe(false)

    await autocomplete.locator("[data-slot='autocomplete-item'][data-value='mira']").click()
    await expect(input).toHaveValue("Mira Chen")
    await expect(hiddenInput).toHaveValue("mira")
  })

  test("disabled listbox items are skipped by keyboard navigation", async ({ page }) => {
    const select = page.locator("[data-slot='select']").filter({ has: page.locator("[data-slot='select-input'][name='plan']") }).first()
    const trigger = select.locator("[data-select-trigger]")

    await select.scrollIntoViewIfNeeded()
    await trigger.focus()
    await page.keyboard.press("ArrowDown")

    const highlighted = select.locator("[data-select-item][data-highlighted='true']").first()
    await expect(highlighted).toBeVisible()
    await expect(highlighted).not.toHaveAttribute("data-disabled", "true")
  })

  test("theme controls apply mode, color, and radius", async ({ page }) => {
    await page.locator(".theme-mode-btn[data-theme-mode='dark']").first().click()
    await expect(page.locator("html")).toHaveClass(/dark/)

    await page.locator("#theme-color [data-select-trigger]").click()
    await page.locator("#theme-color [data-select-item][data-value='slate']").click()
    const primary = await page
      .locator("html")
      .evaluate((el) => getComputedStyle(el).getPropertyValue("--primary").trim())
    expect(primary).toBe("oklch(0.929 0.013 255.508)")

    await page.locator("#theme-radius [data-select-trigger]").click()
    await page.locator("#theme-radius [data-select-item][data-value='vega']").click()
    const radius = await page
      .locator("html")
      .evaluate((el) => getComputedStyle(el).getPropertyValue("--radius").trim())
    expect(radius).toBe("1rem")
  })

  test("command palette opens from sidebar trigger", async ({ page }) => {
    await page.goto("/docs/")

    const trigger = page.locator("[data-open-command-palette]").first()
    const shell = page.locator(".docs-k")
    const input = page.locator(".docs-k-input")
    const listItems = page.locator(".docs-k-item")

    await trigger.scrollIntoViewIfNeeded()
    await expect(trigger).toBeVisible()

    await trigger.click()

    await expect(shell).toBeVisible()
    await expect(shell).not.toHaveClass(/hidden/)
    await expect(trigger).toHaveAttribute("aria-expanded", "true")
    await expect(input).toBeFocused()
    await expect(listItems.first()).toBeVisible()

    await page.keyboard.press("Escape")
    await expect(shell).toHaveClass(/hidden/)
    await expect(trigger).toHaveAttribute("aria-expanded", "false")
  })
})

test.describe("page integrity", () => {
  test("home/docs/component have no console errors or failed requests", async ({ page }) => {
    const consoleErrors: string[] = []
    const failedRequests: string[] = []

    page.on("console", (msg) => {
      if (msg.type() === "error") {
        consoleErrors.push(msg.text())
      }
    })

    page.on("requestfailed", (request) => {
      failedRequests.push(`${request.method()} ${request.url()} ${request.failure()?.errorText || ""}`)
    })

    await page.goto("/")
    await page.goto("/docs/")

    const firstEntryHref = await page.locator("[data-component-card] a").first().getAttribute("href")
    expect(firstEntryHref).toBeTruthy()
    await page.goto(firstEntryHref ?? "/docs/")

    expect(consoleErrors).toEqual([])
    expect(failedRequests).toEqual([])
  })
})
