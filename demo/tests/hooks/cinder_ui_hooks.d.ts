declare module "../../../priv/templates/cinder_ui/index.js" {
  export const CinderUIHooks: Record<string, object>
  export const CinderUI: {
    dispatchCommand: (target: HTMLElement | null, command: string, detail?: object) => void
  }
}

declare module "../../../dev/assets/docs/static_docs.js" {
  export const shouldMountStaticHooks: () => boolean
  export const mountStaticHook: (el: HTMLElement) => boolean
  export const initializeStaticHooks: () => void
}

interface Window {
  CinderUIStaticHookNames?: string[]
  CinderUIStaticUsedHooks?: string[]
  CinderUIStaticMissingHooks?: string[]
}
