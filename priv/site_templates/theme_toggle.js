(() => {
  const storageKey = "cui:theme:mode";
  const root = document.documentElement;
  const buttons = Array.from(document.querySelectorAll("[data-theme-mode]"));
  const media = window.matchMedia("(prefers-color-scheme: dark)");

  const resolveMode = (mode) => (mode === "auto" ? (media.matches ? "dark" : "light") : mode);
  const readMode = () => localStorage.getItem(storageKey) || "auto";

  const apply = () => {
    const mode = readMode();
    const resolvedMode = resolveMode(mode);
    root.classList.toggle("dark", resolvedMode === "dark");
    root.dataset.themeMode = mode;

    buttons.forEach((button) => {
      const active = button.dataset.themeMode === mode;
      button.dataset.active = active ? "true" : "false";
      button.dataset.state = active ? "active" : "inactive";
      button.setAttribute("aria-pressed", active ? "true" : "false");
      button.setAttribute("aria-selected", active ? "true" : "false");
      button.setAttribute("tabindex", active ? "0" : "-1");
    });
  };

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      const mode = button.dataset.themeMode || "auto";
      try {
        localStorage.setItem(storageKey, mode);
      } catch (_error) {}
      apply();
    });
  });

  if (typeof media.addEventListener === "function") {
    media.addEventListener("change", () => {
      if (readMode() === "auto") apply();
    });
  }

  apply();
})();
