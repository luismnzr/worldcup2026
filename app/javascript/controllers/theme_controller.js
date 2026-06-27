import { Controller } from "@hotwired/stimulus"

// Toggles between light and dark mode and persists the choice in
// localStorage. The initial theme is applied by an inline script in the
// layout <head> to avoid a flash of the wrong theme on load.
export default class extends Controller {
  static targets = ["sunIcon", "moonIcon"]
  static values = { storageKey: { type: String, default: "theme" } }

  connect() {
    this.syncIcons()
    this.boundSyncIcons = this.syncIcons.bind(this)
    document.addEventListener("turbo:load", this.boundSyncIcons)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundSyncIcons)
  }

  toggle() {
    const next = document.documentElement.classList.contains("dark") ? "light" : "dark"
    this.apply(next)
    try { localStorage.setItem(this.storageKeyValue, next) } catch (_) {}
    this.syncIcons()
  }

  apply(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark")
  }

  syncIcons() {
    const isDark = document.documentElement.classList.contains("dark")
    this.sunIconTargets.forEach(el => el.classList.toggle("hidden", isDark))
    this.moonIconTargets.forEach(el => el.classList.toggle("hidden", !isDark))
  }
}
