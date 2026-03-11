declare module "../../../priv/templates/cinder_ui.js" {
  export const CinderUIHooks: Record<string, object>
  export const CinderUI: {
    dispatchCommand: (target: HTMLElement | null, command: string, detail?: object) => void
  }
}
