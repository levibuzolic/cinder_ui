import { defineConfig, type PlaywrightTestConfig } from "@playwright/test"

const config = {
  testDir: "./tests/browser",
  snapshotPathTemplate: "{testDir}/{testFilePath}-snapshots/{arg}{ext}",
  timeout: 60_000,
  expect: {
    timeout: 10_000,
    toHaveScreenshot: {
      animations: "disabled",
      caret: "hide",
      maxDiffPixelRatio: 0.015,
      scale: "css",
    },
  },
  fullyParallel: false,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [["list"]],
  use: {
    baseURL: "http://127.0.0.1:4000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "off",
  },
  webServer: {
    command: "mix phx.server",
    url: "http://127.0.0.1:4000",
    cwd: __dirname,
    reuseExistingServer: true,
    timeout: 120_000,
  },
} satisfies PlaywrightTestConfig

export default defineConfig(config)
