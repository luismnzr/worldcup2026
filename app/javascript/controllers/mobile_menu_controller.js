import { Controller } from "@hotwired/stimulus"

// Off-canvas sidebar controller used by the admin dashboard and the public navbar.
//
// The sidebar's default state is controlled via CSS: on mobile the `menu`
// target is translated off-screen; on desktop it's visible. Opening the menu
// adds the `open` class (which the admin sidebar CSS uses to translate back
// in). For the public navbar mobile menu, we also toggle `hidden` so it
// appears/disappears below the navbar.
export default class extends Controller {
  static targets = ["menu", "backdrop"]

  connect() {
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    this.boundClose = this.close.bind(this)
    document.addEventListener("keydown", this.boundCloseOnEscape)
    document.addEventListener("turbo:before-visit", this.boundClose)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundCloseOnEscape)
    document.removeEventListener("turbo:before-visit", this.boundClose)
    document.body.classList.remove("overflow-hidden")
  }

  toggle(event) {
    if (event && typeof event.preventDefault === "function") {
      event.preventDefault()
    }
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.add("open")
    this.menuTarget.classList.remove("hidden")
    if (this.hasBackdropTarget) this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.remove("open")
    this.menuTarget.classList.add("hidden")
    if (this.hasBackdropTarget) this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  isOpen() {
    return this.hasMenuTarget && this.menuTarget.classList.contains("open")
  }
}
