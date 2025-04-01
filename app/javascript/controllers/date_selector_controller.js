import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthDisplay"]

  connect() {
    // ไม่ต้องทำอะไร เพราะไม่มี date picker แล้ว
  }

  select(event) {
    event.preventDefault()
    const url = new URL(event.currentTarget.href)
    const date = url.searchParams.get('date')
    
    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    }).then(response => {
      window.history.pushState({}, '', url)
    })
  }

  previousWeek(event) {
    event.preventDefault()
    const startDate = new Date(event.currentTarget.dataset.startDate)
    const newStartDate = new Date(startDate)
    newStartDate.setDate(startDate.getDate() - 7)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    }).then(response => {
      window.history.pushState({}, '', url)
    })
  }

  nextWeek(event) {
    event.preventDefault()
    const startDate = new Date(event.currentTarget.dataset.startDate)
    const newStartDate = new Date(startDate)
    newStartDate.setDate(startDate.getDate() + 7)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    }).then(response => {
      window.history.pushState({}, '', url)
    })
  }
} 