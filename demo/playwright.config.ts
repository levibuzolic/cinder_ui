import { defineConfig, type PlaywrightTestConfig } from "@playwright/test"

const config = {
  testDir: "./tests/browser",
  globalSetup: "./tests/browser/global_setup.ts",
  snapshotPathTemplate: "{testDir}/{testFilePath}-snapshots/{arg}{ext}",
  timeout: 60_000,
  expect: {
    timeout: 2_000,
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
    launchOptions: process.env.PLAYWRIGHT_CHROME_EXECUTABLE
      ? { executablePath: process.env.PLAYWRIGHT_CHROME_EXECUTABLE }
      : undefined,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "off",
  },
  webServer: {
    command: "mix do app.config --no-validate-compile-env + phx.server",
    url: "http://127.0.0.1:4000",
    cwd: __dirname,
    reuseExistingServer: true,
    timeout: 60_000,
    env: { ...process.env, PHX_CODE_RELOADER: "false" },
  },
} satisfies PlaywrightTestConfig

export default defineConfig(config)
