import { expect, test } from "@playwright/test"

test.describe("component catalog", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/docs/")
  })

  test("renders every component card", async ({ page }) => {
    const cards = page.locator("[data-component-card]")
    const count = await cards.count()

    expect(count).toBeGreaterThan(0)

    for (let i = 0; i < count; i += 1) {
      const card = cards.nth(i)
      await expect(card).toBeVisible()
      await expect(card.locator("h4 code")).toBeVisible()
    }

    await expect(page.locator("text=Render error")).toHaveCount(0)
  })

  test("sidebar navigation renders section and component links", async ({ page }) => {
    const sidebar = page.locator("nav[aria-label='Component sections']")

    await expect(sidebar).toBeVisible()
    await expect(sidebar.getByRole("link", { name: "Actions" })).toBeVisible()
    await expect(sidebar.getByRole("link", { name: "button", exact: true })).toBeVisible()
  })

  test("cards expose HEEx snippets", async ({ page }) => {
    const firstCard = page.locator("[data-component-card]").first()
    await expect(firstCard.getByRole("button", { name: "Copy HEEx" })).toBeVisible()

    const code = firstCard.locator("code[id^='code-']").first()
    await expect(code).toContainText("<.")
  })

  test("overview and detail pages show runtime badges", async ({ page }) => {
    const progressiveBadge = page.locator("[data-component-runtime][data-runtime-kind='progressive']").first()
    await expect(progressiveBadge).toBeVisible()
    await expect(progressiveBadge).toContainText("Progressive")

    const progressiveBadgePill = progressiveBadge.locator("[data-slot='badge']").first()
    await progressiveBadgePill.hover()
    await expect(progressiveBadge.locator("[role='tooltip']").first()).toBeVisible()

    await page.getByRole("link", { name: /Forms\.select/i }).click()
    const detailRuntime = page.locator("[data-component-runtime][data-runtime-kind='progressive']").first()
    await expect(detailRuntime).toBeVisible()
    await expect(detailRuntime.locator("p")).toContainText("optional LiveView hooks for richer behavior")
  })
})
