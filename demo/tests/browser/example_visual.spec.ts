import { expect, test, type Page } from "@playwright/test"

const fixedPreviewWidthPx = 550
const screenshotCss = `
  *, *::before, *::after {
    animation: none !important;
    transition: none !important;
    caret-color: transparent !important;
  }

  body, button, input, select, textarea {
    font-family: Arial, Helvetica, sans-serif !important;
  }

  code, pre {
    font-family: "Courier New", monospace !important;
  }

  [data-component-example] [data-slot="preview"] {
    width: ${fixedPreviewWidthPx}px !important;
    min-width: ${fixedPreviewWidthPx}px !important;
    max-width: ${fixedPreviewWidthPx}px !important;
    overflow: hidden !important;
  }
`

const slugify = (value: string) => value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "")

const gotoWithStableStyles = async (page: Page, path: string) => {
  await page.goto(path)
  await page.addStyleTag({ content: screenshotCss })
}

test.describe("promoted example visual regression", () => {
  test.setTimeout(300_000)

  test.use({
    viewport: { width: 1600, height: 1200 },
    deviceScaleFactor: 2,
  })

  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("cui:theme:mode", "light")
      localStorage.setItem("cui:theme:color", "neutral")
      localStorage.setItem("cui:theme:radius", "nova")
    })
  })

  test("captures docs examples marked with the vrt fence flag", async ({ page }) => {
    await gotoWithStableStyles(page, "/docs/")

    const componentPaths = await page.locator("nav[aria-label='Component sections'] a[href^='/docs/']").evaluateAll(
      (links) =>
        Array.from(
          new Set(
            links
              .map((link) => link.getAttribute("href") || "")
              .filter((href) => href.startsWith("/docs/") && href !== "/docs" && !href.includes("#")),
          ),
        ),
    )

    const promotedExamples: Array<{ componentId: string; exampleId: string; exampleTitle: string; path: string }> = []

    for (const path of componentPaths) {
      await gotoWithStableStyles(page, path)

      const examples = await page.locator("[data-component-example][data-promoted-visual]").evaluateAll((nodes) =>
        nodes.map((node) => ({
          componentId: node.getAttribute("data-component-id") || "",
          exampleId: node.getAttribute("data-example-id") || "",
          exampleTitle: node.getAttribute("data-example-title") || "",
        })),
      )

      promotedExamples.push(...examples.map((example) => ({ ...example, path })))
    }

    expect(promotedExamples.length).toBeGreaterThan(0)

    for (const { componentId, exampleId, exampleTitle, path } of promotedExamples) {
      await gotoWithStableStyles(page, path)

      const example = page.locator(
        `[data-component-example][data-component-id="${componentId}"][data-example-id="${exampleId}"][data-promoted-visual]`,
      )
      const preview = example.locator('[data-slot="preview"]')

      await preview.scrollIntoViewIfNeeded()
      await expect(preview).toBeVisible()
      await expect(preview).toHaveScreenshot(`examples/${componentId}-${slugify(exampleTitle)}.png`, {
        scale: "device",
      })
    }
  })
})
