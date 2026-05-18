import { Controller } from "@hotwired/stimulus"

// Auto-dismiss Bootstrap alerts; pause while hovered for keyboard/pointer users.
export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    this.scheduleDismiss()
  }

  disconnect() {
    this.clearTimer()
  }

  pause() {
    this.clearTimer()
  }

  resume() {
    this.scheduleDismiss()
  }

  scheduleDismiss() {
    this.clearTimer()
    this.timeoutId = window.setTimeout(() => this.dismiss(), this.dismissAfterValue)
  }

  clearTimer() {
    if (this.timeoutId) {
      window.clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }

  dismiss() {
    if (window.bootstrap?.Alert) {
      window.bootstrap.Alert.getOrCreateInstance(this.element).close()
    } else {
      this.element.remove()
    }
  }
}
