import { Controller } from "@hotwired/stimulus"

// Live character count for textareas / inputs with a maxlength.
// Usage:
//   <div data-controller="character-counter">
//     <textarea data-character-counter-target="input" maxlength="5000"></textarea>
//     <small data-character-counter-target="counter"></small>
//   </div>
export default class extends Controller {
  static targets = ["input", "counter"]
  static values = {
    warningRatio: { type: Number, default: 0.9 }
  }

  connect() {
    if (!this.hasInputTarget || !this.hasCounterTarget) return
    this.update()
  }

  update() {
    const max = parseInt(this.inputTarget.getAttribute("maxlength"), 10)
    const current = this.inputTarget.value.length

    if (Number.isNaN(max) || max <= 0) {
      this.counterTarget.textContent = `${current}`
      return
    }

    this.counterTarget.textContent = `${current} / ${max}`
    this.counterTarget.classList.remove("char-counter--warning", "char-counter--danger")

    const ratio = current / max
    if (current >= max) {
      this.counterTarget.classList.add("char-counter--danger")
    } else if (ratio >= this.warningRatioValue) {
      this.counterTarget.classList.add("char-counter--warning")
    }
  }
}
