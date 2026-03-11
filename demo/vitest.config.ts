import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "jsdom",
    environmentOptions: {
      jsdom: {
        url: "http://localhost/",
      },
    },
    include: ["tests/hooks/**/*.test.ts"],
    setupFiles: ["tests/hooks/setup.ts"],
  },
})
