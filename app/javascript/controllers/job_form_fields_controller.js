import { Controller } from "@hotwired/stimulus"

// Toggles job-form fields based on the selected status.
// When status === "accepted", the deadline field is hidden because a deadline
// no longer applies once an offer has been accepted — the start date is what
// matters at that point.
//
// Usage:
//   <div data-controller="job-form-fields">
//     <select data-job-form-fields-target="status"
//             data-action="change->job-form-fields#toggle">...</select>
//     <div data-job-form-fields-target="deadline">...deadline field...</div>
//   </div>
export default class extends Controller {
  static targets = ["status", "deadline"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (!this.hasStatusTarget || !this.hasDeadlineTarget) return
    const isAccepted = this.statusTarget.value === "accepted"
    this.deadlineTarget.hidden = isAccepted
  }
}
