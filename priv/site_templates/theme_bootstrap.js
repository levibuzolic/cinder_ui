(() => {
  const model = globalThis.CinderUIThemeModel;
  if (!model) return;

  const valueSet = (items) => new Set(items.map((item) => item.value));
  const modeValues = valueSet(model.modes);
  const colorValues = valueSet(model.colors);
  const radiusValues = valueSet(model.radii);
  const radiusByValue = Object.fromEntries(model.radii.map((item) => [item.value, item.css]));
  const themedTokenKeys = Array.from(
    new Set(
      Object.values(model.palettes).flatMap((palette) =>
        Object.values(palette).flatMap((tokens) => Object.keys(tokens)),
      ),
    ),
  );

  const storage = model.storage;
  const defaults = model.defaults;
  const mediaQuery = "(prefers-color-scheme: dark)";

  const getMedia = () => {
    if (typeof window === "undefined" || typeof window.matchMedia !== "function") {
      return { matches: false };
    }

    return window.matchMedia(mediaQuery);
  };

  const safeLocalStorageGet = (key) => {
    try {
      return window.localStorage.getItem(key);
    } catch (_error) {
      return null;
    }
  };

  const safeLocalStorageSet = (key, value) => {
    try {
      window.localStorage.setItem(key, value);
    } catch (_error) {
      // localStorage can be blocked in private or embedded browsing contexts.
    }
  };

  const normalizeMode = (mode) => (modeValues.has(mode) ? mode : defaults.mode);
  const normalizeColor = (color) => (colorValues.has(color) ? color : defaults.color);
  const normalizeRadius = (radius) => (radiusValues.has(radius) ? radius : defaults.radius);
  const resolveMode = (mode) => (mode === "auto" ? (getMedia().matches ? "dark" : "light") : mode);

  const readStoredTheme = () => ({
    mode: normalizeMode(safeLocalStorageGet(storage.mode)),
    color: normalizeColor(safeLocalStorageGet(storage.color)),
    radius: normalizeRadius(safeLocalStorageGet(storage.radius)),
  });

  const applyPalette = (root, color, resolvedMode) => {
    const palette = model.palettes[color] || model.palettes[defaults.color];
    const tokens = palette[resolvedMode];

    themedTokenKeys.forEach((token) => {
      root.style.removeProperty(`--${token}`);
    });

    Object.entries(tokens).forEach(([token, value]) => {
      root.style.setProperty(`--${token}`, value);
    });
  };

  const queryAll = (root, selector) => Array.from(root.querySelectorAll(selector));

  const syncSelectControl = (selectRoot, value) => {
    if (!selectRoot) return;

    const input = selectRoot.querySelector("[data-slot='select-input']");
    const valueEl = selectRoot.querySelector("[data-slot='select-value']");
    const items = queryAll(selectRoot, "[data-select-item]");
    const selectedItem = items.find((item) => item.dataset.value === value) || null;
    const placeholder = selectRoot.dataset.placeholder || "";

    if (input) input.value = selectedItem?.dataset.value || "";

    if (valueEl) {
      valueEl.textContent =
        selectedItem?.dataset.label || selectedItem?.textContent?.trim() || placeholder;
    }

    const trigger = selectRoot.querySelector("[data-select-trigger]");
    if (trigger) trigger.classList.toggle("text-muted-foreground", !selectedItem);

    items.forEach((item) => {
      const selected = item === selectedItem;
      item.dataset.selected = selected ? "true" : "false";
      item.setAttribute("aria-selected", selected ? "true" : "false");

      const check = item.querySelector("[data-slot='select-check']");
      if (check) check.classList.toggle("hidden", !selected);
    });
  };

  const syncThemeControls = ({ mode, color, radius }, doc = document) => {
    queryAll(doc, ".theme-mode-btn[data-theme-mode]").forEach((button) => {
      const active = button.dataset.themeMode === mode;
      button.dataset.active = active ? "true" : "false";
      button.dataset.state = active ? "active" : "inactive";
      button.setAttribute("aria-pressed", active ? "true" : "false");
      button.setAttribute("aria-selected", active ? "true" : "false");
    });

    syncSelectControl(doc.querySelector("#theme-color[data-slot='select']"), color);
    syncSelectControl(doc.querySelector("#theme-radius[data-slot='select']"), radius);
  };

  const applyThemeState = (state, options = {}) => {
    const root = options.root || document.documentElement;
    const doc = root.ownerDocument || document;
    const mode = normalizeMode(state.mode);
    const color = normalizeColor(state.color);
    const radius = normalizeRadius(state.radius);
    const resolvedMode = resolveMode(mode);

    root.classList.toggle("dark", resolvedMode === "dark");
    root.dataset.theme = resolvedMode;
    root.dataset.themeMode = mode;
    root.dataset.themeColor = color;
    root.dataset.themeRadius = radius;
    applyPalette(root, color, resolvedMode);
    root.style.setProperty("--radius", radiusByValue[radius] || radiusByValue[defaults.radius]);

    if (options.syncControls !== false) syncThemeControls({ mode, color, radius }, doc);

    return { mode, color, radius, resolvedMode };
  };

  const applyStoredTheme = (options = {}) => applyThemeState(readStoredTheme(), options);

  const setThemeSetting = (setting, value, options = {}) => {
    if (!Object.prototype.hasOwnProperty.call(storage, setting)) return applyStoredTheme(options);

    const normalized =
      setting === "mode"
        ? normalizeMode(value)
        : setting === "color"
          ? normalizeColor(value)
          : normalizeRadius(value);

    safeLocalStorageSet(storage[setting], normalized);
    return applyStoredTheme(options);
  };

  const watchSystemTheme = () => {
    if (globalThis.__cuiThemeSystemWatcher) return;

    const media = getMedia();
    if (typeof media.addEventListener !== "function") return;

    const handler = () => {
      if (readStoredTheme().mode === "auto") applyStoredTheme();
    };

    media.addEventListener("change", handler);
    globalThis.__cuiThemeSystemWatcher = { media, handler };
  };

  const watchThemeStorage = () => {
    if (globalThis.__cuiThemeStorageWatcher || typeof window === "undefined") return;

    const storageKeys = new Set(Object.values(storage));
    const handler = (event) => {
      if (storageKeys.has(event.key)) applyStoredTheme();
    };

    window.addEventListener("storage", handler);
    globalThis.__cuiThemeStorageWatcher = { handler };
  };

  globalThis.CinderUITheme = {
    model,
    storage,
    defaults,
    normalizeMode,
    normalizeColor,
    normalizeRadius,
    resolveMode,
    readStoredTheme,
    applyThemeState,
    applyStoredTheme,
    setThemeSetting,
    syncThemeControls,
    watchSystemTheme,
    watchThemeStorage,
  };
})();
