import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Set initial state
    this.element.style.transition = 'all 0.3s ease-in-out'
    
    // Auto dismiss after 3 seconds
    setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  close() {
    this.dismiss()
  }

  dismiss() {
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateX(100%)'
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
} 