import { Controller } from "@hotwired/stimulus"

// Toggle all checkboxes matching a CSS class on/off.
// Usage:
//   <button data-controller="select-all"
//           data-action="click->select-all#all"
//           data-select-all-checkbox-class="my-class">Select all</button>
export default class extends Controller {
  static values = {
    checkboxClass: String
  }

  all(event) {
    event.preventDefault()
    this.toggle(true)
  }

  none(event) {
    event.preventDefault()
    this.toggle(false)
  }

  toggle(state) {
    const cls = this.checkboxClassValue
    if (!cls) return
    document.querySelectorAll(`.${cls}`).forEach((box) => {
      box.checked = state
    })
  }
}
