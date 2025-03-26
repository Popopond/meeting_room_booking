import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    startDate: String
  }

  select(event) {
    // ลบ class active จากทุก date box
    document.querySelectorAll('.date-box').forEach(box => {
      box.classList.remove('bg-blue-100', 'border-blue-500')
      box.classList.add('bg-white', 'border-gray-200')
    })

    // เพิ่ม class active ให้กับ date box ที่เลือก
    event.currentTarget.classList.remove('bg-white', 'border-gray-200')
    event.currentTarget.classList.add('bg-blue-100', 'border-blue-500')
  }

  previousWeek(event) {
    event.preventDefault()
    const currentStartDate = new Date(this.element.dataset.startDate)
    const newStartDate = new Date(currentStartDate)
    newStartDate.setDate(currentStartDate.getDate() - 5)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    this.navigateToDate(url)
  }

  nextWeek(event) {
    event.preventDefault()
    const currentStartDate = new Date(this.element.dataset.startDate)
    const newStartDate = new Date(currentStartDate)
    newStartDate.setDate(currentStartDate.getDate() + 5)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    this.navigateToDate(url)
  }

  navigateToDate(url) {
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
} 