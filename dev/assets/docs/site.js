(() => {
  const qs = (root, selector) => Array.from(root.querySelectorAll(selector))
  const toggleVisibility = (el, visible) => {
    if (!el) return
    el.classList.toggle("hidden", !visible)
    el.dataset.state = visible ? "open" : "closed"
  }
  const shared = window.CinderUISiteShared || {}
  const escapeHtml =
    shared.escapeHtml ||
    ((value) =>
      value
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;"))
  const highlightCodeBlocks = shared.highlightCodeBlocks || (() => {})
  const themeStorage = {
    mode: "cui:theme:mode",
    color: "cui:theme:color",
    radius: "cui:theme:radius",
  }
  const themePresets = {
    zinc: {
      light: {
        foreground: "oklch(0.141 0.005 285.823)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.141 0.005 285.823)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.141 0.005 285.823)",
        primary: "oklch(0.21 0.006 285.885)",
        "primary-foreground": "oklch(0.985 0 0)",
        secondary: "oklch(0.967 0.001 286.375)",
        "secondary-foreground": "oklch(0.21 0.006 285.885)",
        muted: "oklch(0.967 0.001 286.375)",
        "muted-foreground": "oklch(0.552 0.016 285.938)",
        accent: "oklch(0.967 0.001 286.375)",
        "accent-foreground": "oklch(0.21 0.006 285.885)",
        border: "oklch(0.92 0.004 286.32)",
        input: "oklch(0.92 0.004 286.32)",
        ring: "oklch(0.705 0.015 286.067)",
      },
      dark: {
        background: "oklch(0.141 0.005 285.823)",
        foreground: "oklch(0.985 0 0)",
        card: "oklch(0.21 0.006 285.885)",
        "card-foreground": "oklch(0.985 0 0)",
        popover: "oklch(0.21 0.006 285.885)",
        "popover-foreground": "oklch(0.985 0 0)",
        primary: "oklch(0.92 0.004 286.32)",
        "primary-foreground": "oklch(0.21 0.006 285.885)",
        secondary: "oklch(0.274 0.006 286.033)",
        "secondary-foreground": "oklch(0.985 0 0)",
        muted: "oklch(0.274 0.006 286.033)",
        "muted-foreground": "oklch(0.705 0.015 286.067)",
        accent: "oklch(0.274 0.006 286.033)",
        "accent-foreground": "oklch(0.985 0 0)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.552 0.016 285.938)",
      },
    },
    slate: {
      light: {
        foreground: "oklch(0.129 0.042 264.695)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.129 0.042 264.695)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.129 0.042 264.695)",
        primary: "oklch(0.208 0.042 265.755)",
        "primary-foreground": "oklch(0.984 0.003 247.858)",
        secondary: "oklch(0.968 0.007 247.896)",
        "secondary-foreground": "oklch(0.208 0.042 265.755)",
        muted: "oklch(0.968 0.007 247.896)",
        "muted-foreground": "oklch(0.554 0.046 257.417)",
        accent: "oklch(0.968 0.007 247.896)",
        "accent-foreground": "oklch(0.208 0.042 265.755)",
        border: "oklch(0.929 0.013 255.508)",
        input: "oklch(0.929 0.013 255.508)",
        ring: "oklch(0.704 0.04 256.788)",
      },
      dark: {
        background: "oklch(0.129 0.042 264.695)",
        foreground: "oklch(0.984 0.003 247.858)",
        card: "oklch(0.208 0.042 265.755)",
        "card-foreground": "oklch(0.984 0.003 247.858)",
        popover: "oklch(0.208 0.042 265.755)",
        "popover-foreground": "oklch(0.984 0.003 247.858)",
        primary: "oklch(0.929 0.013 255.508)",
        "primary-foreground": "oklch(0.208 0.042 265.755)",
        secondary: "oklch(0.279 0.041 260.031)",
        "secondary-foreground": "oklch(0.984 0.003 247.858)",
        muted: "oklch(0.279 0.041 260.031)",
        "muted-foreground": "oklch(0.704 0.04 256.788)",
        accent: "oklch(0.279 0.041 260.031)",
        "accent-foreground": "oklch(0.984 0.003 247.858)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.551 0.027 264.364)",
      },
    },
    stone: {
      light: {
        foreground: "oklch(0.147 0.004 49.25)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.147 0.004 49.25)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.147 0.004 49.25)",
        primary: "oklch(0.216 0.006 56.043)",
        "primary-foreground": "oklch(0.985 0.001 106.423)",
        secondary: "oklch(0.97 0.001 106.424)",
        "secondary-foreground": "oklch(0.216 0.006 56.043)",
        muted: "oklch(0.97 0.001 106.424)",
        "muted-foreground": "oklch(0.553 0.013 58.071)",
        accent: "oklch(0.97 0.001 106.424)",
        "accent-foreground": "oklch(0.216 0.006 56.043)",
        border: "oklch(0.923 0.003 48.717)",
        input: "oklch(0.923 0.003 48.717)",
        ring: "oklch(0.709 0.01 56.259)",
      },
      dark: {
        background: "oklch(0.147 0.004 49.25)",
        foreground: "oklch(0.985 0.001 106.423)",
        card: "oklch(0.216 0.006 56.043)",
        "card-foreground": "oklch(0.985 0.001 106.423)",
        popover: "oklch(0.216 0.006 56.043)",
        "popover-foreground": "oklch(0.985 0.001 106.423)",
        primary: "oklch(0.923 0.003 48.717)",
        "primary-foreground": "oklch(0.216 0.006 56.043)",
        secondary: "oklch(0.268 0.007 34.298)",
        "secondary-foreground": "oklch(0.985 0.001 106.423)",
        muted: "oklch(0.268 0.007 34.298)",
        "muted-foreground": "oklch(0.709 0.01 56.259)",
        accent: "oklch(0.268 0.007 34.298)",
        "accent-foreground": "oklch(0.985 0.001 106.423)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.553 0.013 58.071)",
      },
    },
    gray: {
      light: {
        foreground: "oklch(0.13 0.028 261.692)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.13 0.028 261.692)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.13 0.028 261.692)",
        primary: "oklch(0.21 0.034 264.665)",
        "primary-foreground": "oklch(0.985 0.002 247.839)",
        secondary: "oklch(0.967 0.003 264.542)",
        "secondary-foreground": "oklch(0.21 0.034 264.665)",
        muted: "oklch(0.967 0.003 264.542)",
        "muted-foreground": "oklch(0.551 0.027 264.364)",
        accent: "oklch(0.967 0.003 264.542)",
        "accent-foreground": "oklch(0.21 0.034 264.665)",
        border: "oklch(0.928 0.006 264.531)",
        input: "oklch(0.928 0.006 264.531)",
        ring: "oklch(0.707 0.022 261.325)",
      },
      dark: {
        background: "oklch(0.13 0.028 261.692)",
        foreground: "oklch(0.985 0.002 247.839)",
        card: "oklch(0.21 0.034 264.665)",
        "card-foreground": "oklch(0.985 0.002 247.839)",
        popover: "oklch(0.21 0.034 264.665)",
        "popover-foreground": "oklch(0.985 0.002 247.839)",
        primary: "oklch(0.928 0.006 264.531)",
        "primary-foreground": "oklch(0.21 0.034 264.665)",
        secondary: "oklch(0.278 0.033 256.848)",
        "secondary-foreground": "oklch(0.985 0.002 247.839)",
        muted: "oklch(0.278 0.033 256.848)",
        "muted-foreground": "oklch(0.707 0.022 261.325)",
        accent: "oklch(0.278 0.033 256.848)",
        "accent-foreground": "oklch(0.985 0.002 247.839)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.551 0.027 264.364)",
      },
    },
    neutral: {
      light: {
        foreground: "oklch(0.145 0 0)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.145 0 0)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.145 0 0)",
        primary: "oklch(0.205 0 0)",
        "primary-foreground": "oklch(0.985 0 0)",
        secondary: "oklch(0.97 0 0)",
        "secondary-foreground": "oklch(0.205 0 0)",
        muted: "oklch(0.97 0 0)",
        "muted-foreground": "oklch(0.556 0 0)",
        accent: "oklch(0.97 0 0)",
        "accent-foreground": "oklch(0.205 0 0)",
        border: "oklch(0.922 0 0)",
        input: "oklch(0.922 0 0)",
        ring: "oklch(0.708 0 0)",
      },
      dark: {
        background: "oklch(0.145 0 0)",
        foreground: "oklch(0.985 0 0)",
        card: "oklch(0.205 0 0)",
        "card-foreground": "oklch(0.985 0 0)",
        popover: "oklch(0.205 0 0)",
        "popover-foreground": "oklch(0.985 0 0)",
        primary: "oklch(0.922 0 0)",
        "primary-foreground": "oklch(0.205 0 0)",
        secondary: "oklch(0.269 0 0)",
        "secondary-foreground": "oklch(0.985 0 0)",
        muted: "oklch(0.269 0 0)",
        "muted-foreground": "oklch(0.708 0 0)",
        accent: "oklch(0.269 0 0)",
        "accent-foreground": "oklch(0.985 0 0)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.556 0 0)",
      },
    },
  }
  const radiusPresets = {
    maia: "0.375rem",
    mira: "0.5rem",
    nova: "0.75rem",
    lyra: "0.875rem",
    vega: "1rem",
  }
  const themedTokenKeys = Array.from(
    new Set(
      Object.values(themePresets).flatMap((palette) =>
        Object.values(palette).flatMap((modeTokens) => Object.keys(modeTokens))
      )
    )
  )
  const media = window.matchMedia("(prefers-color-scheme: dark)")
  const root = document.documentElement
  const sidebar = document.querySelector("[data-docs-sidebar]")
  const modeButtons = qs(document, "[data-theme-mode]")
  const colorSelect = document.querySelector("#theme-color [data-slot='select-input']")
  const radiusSelect = document.querySelector("#theme-radius [data-slot='select-input']")
  const sidebarScrollStorageKey = "cui:docs:sidebar-scroll-top"

  const restoreSidebarScroll = () => {
    if (!sidebar) return

    try {
      const saved = Number.parseInt(sessionStorage.getItem(sidebarScrollStorageKey) || "", 10)
      if (!Number.isFinite(saved) || saved < 0) return

      // Delay until layout is stable so the sticky sidebar has final height.
      requestAnimationFrame(() => {
        sidebar.scrollTop = saved
      })
    } catch (_error) {
      // no-op
    }
  }

  const persistSidebarScroll = () => {
    if (!sidebar) return
    try {
      sessionStorage.setItem(sidebarScrollStorageKey, String(sidebar.scrollTop))
    } catch (_error) {
      // no-op
    }
  }

  const readSetting = (key, fallback) => localStorage.getItem(key) || fallback
  const writeSetting = (key, value) => localStorage.setItem(key, value)
  const resolveMode = (mode) => (mode === "auto" ? (media.matches ? "dark" : "light") : mode)

  const applyPalette = (color, resolvedMode) => {
    const palette = themePresets[color] || themePresets.neutral
    const tokens = palette[resolvedMode]
    themedTokenKeys.forEach((token) => {
      root.style.removeProperty(`--${token}`)
    })
    Object.entries(tokens).forEach(([token, value]) => {
      root.style.setProperty(`--${token}`, value)
    })
  }

  const syncThemeControls = (mode, color, radius) => {
    modeButtons.forEach((button) => {
      const active = button.dataset.themeMode === mode
      button.dataset.active = active ? "true" : "false"
      button.dataset.state = active ? "active" : "inactive"
      button.setAttribute("aria-pressed", active ? "true" : "false")
      button.setAttribute("aria-selected", active ? "true" : "false")
    })

    if (colorSelect) colorSelect.value = color
    if (radiusSelect) radiusSelect.value = radius
  }

  const applyTheme = () => {
    const mode = readSetting(themeStorage.mode, "auto")
    const color = readSetting(themeStorage.color, "neutral")
    const radius = readSetting(themeStorage.radius, "nova")
    const resolvedMode = resolveMode(mode)
    root.classList.toggle("dark", resolvedMode === "dark")
    applyPalette(color, resolvedMode)
    root.style.setProperty("--radius", radiusPresets[radius] || radiusPresets.nova)
    syncThemeControls(mode, color, radius)
  }

  modeButtons.forEach((button) => {
    button.addEventListener("click", () => {
      writeSetting(themeStorage.mode, button.dataset.themeMode || "auto")
      applyTheme()
    })
  })

  colorSelect?.addEventListener("change", () => {
    writeSetting(themeStorage.color, colorSelect.value)
    applyTheme()
  })

  radiusSelect?.addEventListener("change", () => {
    writeSetting(themeStorage.radius, radiusSelect.value)
    applyTheme()
  })

  if (typeof media.addEventListener === "function") {
    media.addEventListener("change", () => {
      if (readSetting(themeStorage.mode, "auto") === "auto") applyTheme()
    })
  }

  applyTheme()
  restoreSidebarScroll()
  highlightCodeBlocks()

  sidebar?.addEventListener("scroll", persistSidebarScroll, { passive: true })
  qs(sidebar || document, "a[href]").forEach((link) => {
    link.addEventListener("click", persistSidebarScroll)
  })
  window.addEventListener("beforeunload", persistSidebarScroll)

  const initCommandPalette = () => {
    const navLinks = qs(document, "nav[aria-label='Component sections'] ul li a[href]")
    const items = []
    const seen = new Set()

    navLinks.forEach((link) => {
      const hrefAttr = link.getAttribute("href")
      if (!hrefAttr) return

      const href = new URL(hrefAttr, window.location.href).toString()
      if (seen.has(href)) return
      seen.add(href)

      const sectionLink = link.closest("ul")?.previousElementSibling
      const moduleName = (sectionLink?.textContent || "").trim()
      const title = (link.textContent || "").trim()
      const displayName = moduleName ? `${moduleName}.${title}` : title

      items.push({
        title,
        moduleName,
        displayName,
        queryText: `${displayName} ${title} ${moduleName}`.toLowerCase(),
        href,
      })
    })

    if (!items.length) return

    const openButtons = qs(document, "[data-open-command-palette]")

    const shell = document.createElement("div")
    shell.className = "docs-k hidden"
    shell.innerHTML = `
      <div class="docs-k-backdrop" data-k-close></div>
      <div class="docs-k-panel" role="dialog" aria-modal="true" aria-label="Jump to component">
        <div class="docs-k-input-row">
          <input type="text" class="docs-k-input" placeholder="Jump to component..." />
        </div>
        <ul class="docs-k-list"></ul>
      </div>
    `
    document.body.appendChild(shell)

    const input = shell.querySelector(".docs-k-input")
    const list = shell.querySelector(".docs-k-list")
    let filtered = items.slice()
    let activeIndex = 0

    const syncOpenButtons = (open) => {
      openButtons.forEach((button) => {
        button.dataset.state = open ? "active" : "inactive"
        button.setAttribute("aria-expanded", open ? "true" : "false")
      })
    }

    const close = () => {
      shell.classList.add("hidden")
      document.body.style.removeProperty("overflow")
      syncOpenButtons(false)
    }

    const open = () => {
      shell.classList.remove("hidden")
      document.body.style.overflow = "hidden"
      input.value = ""
      activeIndex = 0
      render()
      syncOpenButtons(true)
      requestAnimationFrame(() => input.focus())
    }

    openButtons.forEach((button) => {
      button.addEventListener("click", () => {
        open()
      })
    })

    const navigate = (item) => {
      if (!item) return
      window.location.assign(item.href)
    }

    const render = () => {
      const query = (input.value || "").trim().toLowerCase()
      filtered = query
        ? items.filter((item) => item.queryText.includes(query))
        : items.slice()

      const visibleCount = Math.min(filtered.length, 24)
      if (activeIndex >= visibleCount) activeIndex = 0

      if (!filtered.length) {
        list.innerHTML = `<li class="docs-k-empty">No components found.</li>`
        return
      }

      list.innerHTML = filtered
        .slice(0, 24)
        .map((item, index) => {
          const active = index === activeIndex ? "true" : "false"
          const label = escapeHtml(item.displayName)
          const meta = item.moduleName ? escapeHtml(item.moduleName) : "Component"
          return `<li><button type="button" class="docs-k-item" data-index="${index}" data-active="${active}"><span class="docs-k-item-label">${label}</span><span class="docs-k-item-meta">${meta}</span></button></li>`
        })
        .join("")

      const activeButton = list.querySelector(`.docs-k-item[data-index="${activeIndex}"]`)
      activeButton?.scrollIntoView({ block: "nearest" })
    }

    shell.addEventListener("click", (event) => {
      if (event.target.closest("[data-k-close]")) {
        close()
        return
      }

      const item = event.target.closest(".docs-k-item")
      if (!item) return
      const index = Number.parseInt(item.dataset.index || "0", 10)
      navigate(filtered[index])
    })

    input.addEventListener("input", () => {
      activeIndex = 0
      render()
    })

    input.addEventListener("keydown", (event) => {
      const visibleCount = Math.min(filtered.length, 24)

      if (event.key === "ArrowDown") {
        event.preventDefault()
        if (!visibleCount) return
        activeIndex = (activeIndex + 1) % visibleCount
        render()
        return
      }

      if (event.key === "ArrowUp") {
        event.preventDefault()
        if (!visibleCount) return
        activeIndex = (activeIndex - 1 + visibleCount) % visibleCount
        render()
        return
      }

      if (event.key === "Enter") {
        event.preventDefault()
        navigate(filtered[activeIndex])
        return
      }

      if (event.key === "Escape") {
        event.preventDefault()
        close()
      }
    })

    document.addEventListener("keydown", (event) => {
      const wantsPalette = (event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k"
      if (wantsPalette) {
        event.preventDefault()
        if (shell.classList.contains("hidden")) open()
        else close()
        return
      }

      if (event.key === "Escape" && !shell.classList.contains("hidden")) {
        event.preventDefault()
        close()
      }
    })
  }

  initCommandPalette()

  const copyButtons = Array.from(document.querySelectorAll("[data-copy-template]"))
  copyButtons.forEach((button) => {
    button.addEventListener("click", async () => {
      const id = button.getAttribute("data-copy-template")
      const code = document.getElementById(`code-${id}`)
      if (!code) return

      const text = code.textContent || ""
      try {
        await navigator.clipboard.writeText(text)
        const original = button.innerHTML
        button.innerHTML = "✓"
        setTimeout(() => {
          button.innerHTML = original
        }, 1200)
      } catch (_error) {
        // no-op
      }
    })
  })

  // Dialogs (includes alert dialogs)
  qs(document, "[data-slot='dialog']").forEach((root) => {
    const overlay = root.querySelector("[data-dialog-overlay]")
    const content = root.querySelector("[data-dialog-content]")

    const sync = (open) => {
      root.dataset.state = open ? "open" : "closed"
      toggleVisibility(overlay, open)
      toggleVisibility(content, open)
    }

    root.addEventListener("click", (event) => {
      if (event.target.closest("[data-dialog-trigger]")) sync(true)
      if (event.target.closest("[data-dialog-close]") || event.target.closest("[data-dialog-overlay]")) sync(false)
    })

    sync(root.dataset.state === "open")
  })

  // Drawers / sheets
  qs(document, "[data-slot='drawer']").forEach((root) => {
    const overlay = root.querySelector("[data-drawer-overlay]")
    const content = root.querySelector("[data-drawer-content]")

    const sync = (open) => {
      root.dataset.state = open ? "open" : "closed"
      toggleVisibility(overlay, open)
      toggleVisibility(content, open)
    }

    root.addEventListener("click", (event) => {
      if (event.target.closest("[data-drawer-trigger]")) sync(true)
      if (event.target.closest("[data-drawer-overlay]")) sync(false)
    })

    sync(root.dataset.state === "open")
  })

  // Popovers
  qs(document, "[data-slot='popover']").forEach((root) => {
    const trigger = root.querySelector("[data-popover-trigger]")
    const content = root.querySelector("[data-popover-content]")
    let open = false

    trigger?.addEventListener("click", (event) => {
      event.preventDefault()
      open = !open
      toggleVisibility(content, open)
    })

    document.addEventListener("click", (event) => {
      if (!root.contains(event.target)) {
        open = false
        toggleVisibility(content, false)
      }
    })
  })

  // Dropdown menus
  qs(document, "[data-slot='dropdown-menu']").forEach((root) => {
    const trigger = root.querySelector("[data-dropdown-trigger]")
    const content = root.querySelector("[data-dropdown-content]")
    let open = false

    trigger?.addEventListener("click", (event) => {
      event.preventDefault()
      open = !open
      toggleVisibility(content, open)
    })

    document.addEventListener("click", (event) => {
      if (!root.contains(event.target)) {
        open = false
        toggleVisibility(content, false)
      }
    })
  })

  // Combobox previews
  qs(document, "[data-slot='combobox']").forEach((root) => {
    const input = root.querySelector("[data-combobox-input]")
    const content = root.querySelector("[data-combobox-content]")
    const items = qs(root, "[data-slot='combobox-item']")

    input?.addEventListener("focus", () => toggleVisibility(content, true))
    input?.addEventListener("input", () => {
      const value = (input.value || "").toLowerCase()
      items.forEach((item) => {
        const text = (item.textContent || "").toLowerCase()
        item.classList.toggle("hidden", !text.includes(value))
      })
      toggleVisibility(content, true)
    })

    items.forEach((item) => {
      item.addEventListener("click", () => {
        input.value = item.getAttribute("data-value") || (item.textContent || "").trim()
        toggleVisibility(content, false)
      })
    })

    document.addEventListener("click", (event) => {
      if (!root.contains(event.target)) {
        toggleVisibility(content, false)
      }
    })
  })

  // Autocomplete previews
  qs(document, "[data-slot='autocomplete']").forEach((root) => {
    const input = root.querySelector("[data-autocomplete-input]")
    const content = root.querySelector("[data-autocomplete-content]")
    const valueInput = root.querySelector("[data-slot='autocomplete-value']")
    const items = qs(root, "[data-slot='autocomplete-item']")
    const empty = root.querySelector("[data-slot='autocomplete-empty']")
    let selectedLabel = root.getAttribute("data-selected-label") || ""

    const sync = (open) => {
      toggleVisibility(content, open)
      input?.setAttribute("aria-expanded", open ? "true" : "false")
      root.dataset.state = open ? "open" : "closed"
    }

    const syncEmpty = () => {
      if (!empty) return
      const hasVisibleItems = items.some((item) => !item.classList.contains("hidden"))
      empty.classList.toggle("hidden", hasVisibleItems)
    }

    const filterItems = () => {
      const value = (input?.value || "").toLowerCase()
      items.forEach((item) => {
        const text = (item.getAttribute("data-label") || item.textContent || "").toLowerCase()
        item.classList.toggle("hidden", !text.includes(value))
      })

      if (valueInput && (input?.value || "") !== selectedLabel) {
        valueInput.value = ""
      }

      syncEmpty()
      sync(true)
    }

    input?.addEventListener("focus", () => sync(true))
    input?.addEventListener("input", filterItems)

    items.forEach((item) => {
      item.addEventListener("click", () => {
        if (item.getAttribute("data-disabled") === "true") return
        selectedLabel = item.getAttribute("data-label") || item.textContent || ""
        root.dataset.selectedLabel = selectedLabel
        if (input) input.value = selectedLabel
        if (valueInput) valueInput.value = item.getAttribute("data-value") || ""

        items.forEach((entry) => {
          const selected = entry === item
          entry.dataset.selected = selected ? "true" : "false"
          entry.setAttribute("aria-selected", selected ? "true" : "false")
          entry.classList.toggle("bg-accent", selected)
          entry.classList.toggle("text-accent-foreground", selected)
        })

        sync(false)
      })
    })

    document.addEventListener("click", (event) => {
      if (!root.contains(event.target)) {
        if (input && valueInput?.value) input.value = selectedLabel
        filterItems()
        sync(false)
      }
    })
  })

  // Carousel previews
  qs(document, "[data-slot='carousel']").forEach((root) => {
    const track = root.querySelector("[data-carousel-track]")
    const items = qs(root, "[data-slot='carousel-item']")
    const prev = root.querySelector("[data-carousel-prev]")
    const next = root.querySelector("[data-carousel-next]")
    let index = 0

    const sync = () => {
      if (!track || items.length === 0) return
      track.style.transform = `translateX(-${index * 100}%)`
      track.style.transition = "transform 240ms ease"
    }

    prev?.addEventListener("click", () => {
      index = index === 0 ? items.length - 1 : index - 1
      sync()
    })

    next?.addEventListener("click", () => {
      index = index === items.length - 1 ? 0 : index + 1
      sync()
    })

    sync()
  })
})()
