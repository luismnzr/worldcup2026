import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "userId", "planStatus", "planOk", "planNone", "planOkText", "walkinFlag", "submitBtn"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    // Clear selection when typing
    this.clearSelection()

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.hideResults()
    }
  }

  async fetchResults(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}&role=student`, {
        headers: { "Accept": "application/json" }
      })
      const users = await response.json()
      this.showResults(users)
    } catch (error) {
      this.hideResults()
    }
  }

  showResults(users) {
    if (users.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-[var(--color-muted-foreground)]">No se encontraron alumnos</div>
      `
    } else {
      this.resultsTarget.innerHTML = users.map(user => `
        <button type="button"
                class="w-full flex items-center gap-3 px-4 py-2.5 hover:bg-[var(--color-muted)]/50 transition-colors text-left"
                data-action="click->checkin-search#selectUser"
                data-user-id="${user.id}"
                data-user-name="${this.escapeHtml(user.name)}"
                data-user-email="${this.escapeHtml(user.email)}"
                data-has-plan="${user.has_plan}"
                data-plan-label="${this.escapeHtml(user.plan_label)}">
          <div class="h-8 w-8 rounded-full bg-[var(--color-primary)]/10 flex items-center justify-center flex-shrink-0">
            <span class="text-xs font-medium text-[var(--color-primary)]">${this.escapeHtml(user.initials)}</span>
          </div>
          <div class="min-w-0 flex-1">
            <p class="text-sm font-medium text-[var(--color-foreground)] truncate">${this.escapeHtml(user.name)}</p>
            <p class="text-xs text-[var(--color-muted-foreground)] truncate">${this.escapeHtml(user.email)}</p>
          </div>
          <span class="text-xs text-[var(--color-muted-foreground)] whitespace-nowrap">${this.escapeHtml(user.plan_label)}</span>
        </button>
      `).join("")
    }
    this.resultsTarget.classList.remove("hidden")
  }

  selectUser(event) {
    const btn = event.currentTarget
    const userId = btn.dataset.userId
    const name = btn.dataset.userName
    const email = btn.dataset.userEmail
    const hasPlan = btn.dataset.hasPlan === "true"
    const planLabel = btn.dataset.planLabel

    this.inputTarget.value = `${name} (${email})`
    this.userIdTarget.value = userId
    this.hideResults()

    // Show plan status
    this.planStatusTarget.classList.remove("hidden")
    this.submitBtnTarget.disabled = false

    if (hasPlan) {
      this.planOkTarget.classList.remove("hidden")
      this.planNoneTarget.classList.add("hidden")
      this.planOkTextTarget.textContent = planLabel
      this.walkinFlagTarget.value = "0"
    } else {
      this.planOkTarget.classList.add("hidden")
      this.planNoneTarget.classList.remove("hidden")
      this.walkinFlagTarget.value = "1"
    }
  }

  clearSelection() {
    this.userIdTarget.value = ""
    this.planStatusTarget.classList.add("hidden")
    this.submitBtnTarget.disabled = true
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
