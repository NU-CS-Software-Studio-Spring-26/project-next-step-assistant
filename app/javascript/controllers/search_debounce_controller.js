import { Controller } from "@hotwired/stimulus"

// Auto-submits the parent form after the user stops typing.
// Usage:
//   <input
//     type="text"
//     data-controller="search-debounce"
//     data-action="input->search-debounce#schedule"
//     data-search-debounce-delay-value="400">
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 400 }
  }

  disconnect() {
    this.clear()
  }

  schedule() {
    this.clear()
    this.timeoutId = window.setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    const form = this.element.closest("form")
    if (!form) return
    if (typeof form.requestSubmit === "function") {
      form.requestSubmit()
    } else {
      form.submit()
    }
  }

  clear() {
    if (this.timeoutId) {
      window.clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }
}
