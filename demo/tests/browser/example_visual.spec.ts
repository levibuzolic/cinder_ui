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

    // Pre-filter: only navigate to pages that contain promoted visual examples.
    // Use parallel fetch() to check HTML content without full browser navigation.
    const pagesWithPromoted = await page.evaluate(async (paths) => {
      const results = await Promise.all(
        paths.map(async (path) => {
          const response = await fetch(path)
          const html = await response.text()
          return html.includes("data-promoted-visual") ? path : null
        }),
      )
      return results.filter((path): path is string => path !== null)
    }, componentPaths)

    let promotedCount = 0

    for (const path of pagesWithPromoted) {
      await gotoWithStableStyles(page, path)

      const examples = await page.locator("[data-component-example][data-promoted-visual]").evaluateAll((nodes) =>
        nodes.map((node) => ({
          componentId: node.getAttribute("data-component-id") || "",
          exampleId: node.getAttribute("data-example-id") || "",
          exampleTitle: node.getAttribute("data-example-title") || "",
        })),
      )

      for (const { componentId, exampleId, exampleTitle } of examples) {
        const example = page.locator(
          `[data-component-example][data-component-id="${componentId}"][data-example-id="${exampleId}"][data-promoted-visual]`,
        )
        const preview = example.locator('[data-slot="preview"]')

        await preview.scrollIntoViewIfNeeded()
        await expect(preview).toBeVisible()
        await expect(preview).toHaveScreenshot(`examples/${componentId}-${slugify(exampleTitle)}.png`, {
          scale: "device",
        })
        promotedCount += 1
      }
    }

    expect(promotedCount).toBeGreaterThan(0)
  })
})
