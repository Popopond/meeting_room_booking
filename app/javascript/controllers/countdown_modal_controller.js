import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "countdown"]
  
  connect() {
    this.countdown = 3
    this.startCountdown()
  }

  startCountdown() {
    this.countdownTarget.textContent = this.countdown
    
    const timer = setInterval(() => {
      this.countdown--
      this.countdownTarget.textContent = this.countdown
      
      if (this.countdown <= 0) {
        clearInterval(timer)
        this.modalTarget.remove()
      }
    }, 1000)
  }
} 