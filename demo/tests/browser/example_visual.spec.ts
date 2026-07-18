import { expect, test, type APIRequestContext, type Page } from "@playwright/test"

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
  await page.goto(path, { waitUntil: "domcontentloaded" })
  await page.addStyleTag({ content: screenshotCss })
  await page.evaluate(async () => {
    await document.fonts.ready
    await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())))
  })
}

const pageContainsPromotedExamples = async (request: APIRequestContext, path: string) => {
  const response = await request.get(path)
  const html = await response.text()
  return html.includes("data-promoted-visual")
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

  test("captures docs examples marked with the vrt fence flag", async ({ page, request }) => {
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

    const pagesWithPromoted = (
      await Promise.all(
        componentPaths.map(async (path) => ((await pageContainsPromotedExamples(request, path)) ? path : null)),
      )
    ).filter((path): path is string => path !== null)

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
          animations: "allow",
          scale: "device",
        })
        promotedCount += 1
      }
    }

    expect(promotedCount).toBeGreaterThan(0)
  })
})
