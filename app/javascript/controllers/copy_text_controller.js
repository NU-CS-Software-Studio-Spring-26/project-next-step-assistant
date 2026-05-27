import { Controller } from "@hotwired/stimulus"

// Copies a text input's value to the clipboard and flashes confirmation
// on the trigger button.
//
// Usage:
//   <div data-controller="copy-text">
//     <input data-copy-text-target="source" ...>
//     <button data-action="click->copy-text#copy"
//             data-copy-text-target="button">Copy</button>
//   </div>
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    if (!this.hasSourceTarget) return

    const text = this.sourceTarget.value
    try {
      await navigator.clipboard.writeText(text)
      this.flash("Copied!")
    } catch (_err) {
      this.sourceTarget.select()
      document.execCommand("copy")
      this.flash("Copied!")
    }
  }

  flash(message) {
    if (!this.hasButtonTarget) return
    const original = this.buttonTarget.innerHTML
    this.buttonTarget.innerHTML = `<i class="bi bi-check2 me-1" aria-hidden="true"></i>${message}`
    setTimeout(() => { this.buttonTarget.innerHTML = original }, 1500)
  }
}
