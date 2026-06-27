import { Controller } from "@hotwired/stimulus"

const COUNTRY_CODES = [
  { code: "+52", flag: "\u{1F1F2}\u{1F1FD}", name: "MX", format: "## #### ####", placeholder: "55 1234 5678" },
  { code: "+1", flag: "\u{1F1FA}\u{1F1F8}", name: "US", format: "### ### ####", placeholder: "212 555 1234" },
  { code: "+57", flag: "\u{1F1E8}\u{1F1F4}", name: "CO", format: "### ### ####", placeholder: "301 234 5678" },
  { code: "+54", flag: "\u{1F1E6}\u{1F1F7}", name: "AR", format: "## #### ####", placeholder: "11 2345 6789" },
  { code: "+56", flag: "\u{1F1E8}\u{1F1F1}", name: "CL", format: "# #### ####", placeholder: "9 1234 5678" },
  { code: "+34", flag: "\u{1F1EA}\u{1F1F8}", name: "ES", format: "### ## ## ##", placeholder: "612 34 56 78" },
]

export default class extends Controller {
  static targets = ["hidden", "display", "code", "dropdown"]

  connect() {
    this.countries = COUNTRY_CODES
    this.open = false

    // Parse existing value to detect country code
    const currentValue = this.hiddenTarget.value || ""
    let matched = this.countries.find(c => currentValue.startsWith(c.code))
    this.selectedIndex = matched ? this.countries.indexOf(matched) : 0

    // Set display value from existing hidden value
    if (currentValue) {
      const country = this.countries[this.selectedIndex]
      const digits = currentValue.replace(country.code, "").replace(/\D/g, "")
      this.displayTarget.value = this.formatDigits(digits, country.format)
    }

    this.updateCodeButton()
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  get selectedCountry() {
    return this.countries[this.selectedIndex]
  }

  toggleDropdown(event) {
    event.stopPropagation()
    this.open = !this.open
    this.dropdownTarget.classList.toggle("hidden", !this.open)
  }

  selectCountry(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.selectedIndex = index
    this.updateCodeButton()
    this.open = false
    this.dropdownTarget.classList.add("hidden")
    this.displayTarget.placeholder = this.selectedCountry.placeholder
    // Re-format current digits with new country format
    const digits = this.displayTarget.value.replace(/\D/g, "")
    this.displayTarget.value = this.formatDigits(digits, this.selectedCountry.format)
    this.syncHidden()
    this.displayTarget.focus()
  }

  updateCodeButton() {
    const country = this.selectedCountry
    this.codeTarget.innerHTML = `${country.flag} ${country.code}`
    this.displayTarget.placeholder = country.placeholder
  }

  onInput() {
    const raw = this.displayTarget.value.replace(/\D/g, "")
    const country = this.selectedCountry
    const maxDigits = country.format.replace(/[^#]/g, "").length

    const truncated = raw.slice(0, maxDigits)
    this.displayTarget.value = this.formatDigits(truncated, country.format)
    this.syncHidden()
  }

  formatDigits(digits, format) {
    let result = ""
    let di = 0
    for (let i = 0; i < format.length && di < digits.length; i++) {
      if (format[i] === "#") {
        result += digits[di++]
      } else {
        result += format[i]
      }
    }
    return result
  }

  syncHidden() {
    const digits = this.displayTarget.value.replace(/\D/g, "")
    if (digits.length > 0) {
      this.hiddenTarget.value = `${this.selectedCountry.code}${digits}`
    } else {
      this.hiddenTarget.value = ""
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.open = false
      this.dropdownTarget.classList.add("hidden")
    }
  }
}
