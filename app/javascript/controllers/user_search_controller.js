import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String, indexUrl: String }

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

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  submitSearch(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      clearTimeout(this.timeout)
      this.hideResults()

      const query = this.inputTarget.value.trim()
      const url = new URL(this.indexUrlValue, window.location.origin)

      // Preserve existing params
      const currentParams = new URLSearchParams(window.location.search)
      for (const [key, value] of currentParams) {
        if (key !== "q" && key !== "page") {
          url.searchParams.set(key, value)
        }
      }

      if (query.length > 0) {
        url.searchParams.set("q", query)
      }

      window.location.href = url.toString()
    }
  }

  async fetchResults(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
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
        <div class="px-4 py-3 text-sm text-[var(--color-muted-foreground)]">No se encontraron usuarios</div>
      `
    } else {
      this.resultsTarget.innerHTML = users.map(user => `
        <a href="${user.url}" class="flex items-center gap-3 px-4 py-2.5 hover:bg-[var(--color-muted)]/50 transition-colors">
          <div class="h-8 w-8 rounded-full bg-[var(--color-primary)]/10 flex items-center justify-center flex-shrink-0">
            <span class="text-xs font-medium text-[var(--color-primary)]">${user.initials}</span>
          </div>
          <div class="min-w-0">
            <p class="text-sm font-medium text-[var(--color-foreground)] truncate">${user.name}</p>
            <p class="text-xs text-[var(--color-muted-foreground)] truncate">${user.email}</p>
          </div>
          <span class="ml-auto inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${user.role_class}">
            ${user.role}
          </span>
        </a>
      `).join("")
    }
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  selectAndNavigate(event) {
    const url = event.currentTarget.getAttribute("href")
    if (url) {
      window.location.href = url
    }
  }
}
