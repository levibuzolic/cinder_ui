Object.defineProperty(window, "requestAnimationFrame", {
  value: (callback: FrameRequestCallback) => {
    callback(0)
    return 0
  },
  writable: true,
})

Object.defineProperty(window, "cancelAnimationFrame", {
  value: () => {},
  writable: true,
})

if (!("select" in HTMLInputElement.prototype)) {
  Object.defineProperty(HTMLInputElement.prototype, "select", {
    value() {},
    writable: true,
  })
}

const storage = new Map<string, string>()

Object.defineProperty(window, "localStorage", {
  value: {
    getItem: (key: string) => storage.get(key) ?? null,
    setItem: (key: string, value: string) => {
      storage.set(key, String(value))
    },
    removeItem: (key: string) => {
      storage.delete(key)
    },
    clear: () => {
      storage.clear()
    },
  },
  writable: true,
})
