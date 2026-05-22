import { Controller } from "@hotwired/stimulus"

// Collapses long content with a fade gradient + "Show more" / "Show less" toggle.
// If the content fits without overflow, the toggle hides itself automatically.
//
// Usage:
//   <div class="collapsible" data-controller="collapsible">
//     <div class="collapsible__content" data-collapsible-target="content">
//       ...long content...
//     </div>
//     <button data-action="click->collapsible#toggle"
//             data-collapsible-target="toggle">
//       <span data-collapsible-target="moreLabel">Show more</span>
//       <span data-collapsible-target="lessLabel" hidden>Show less</span>
//     </button>
//   </div>
export default class extends Controller {
  static targets = ["content", "toggle", "moreLabel", "lessLabel"]

  connect() {
    requestAnimationFrame(() => this.maybeHideToggle())
  }

  toggle(event) {
    event.preventDefault()
    const expanded = this.element.classList.toggle("collapsible--expanded")
    if (this.hasMoreLabelTarget) this.moreLabelTarget.hidden = expanded
    if (this.hasLessLabelTarget) this.lessLabelTarget.hidden = !expanded
    this.toggleTarget.setAttribute("aria-expanded", expanded ? "true" : "false")
  }

  maybeHideToggle() {
    if (!this.hasContentTarget || !this.hasToggleTarget) return
    const el = this.contentTarget
    if (el.scrollHeight <= el.clientHeight + 1) {
      this.toggleTarget.hidden = true
      this.element.classList.add("collapsible--no-overflow")
    }
  }
}
