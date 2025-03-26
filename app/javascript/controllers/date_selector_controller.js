import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["datePicker"]

  connect() {
    // ตั้งค่าวันเริ่มต้นเป็นวันนี้
    this.datePickerTarget.value = new Date().toISOString().split('T')[0]
  }

  openDatePicker() {
    this.datePickerTarget.click()
  }

  dateSelected(event) {
    const selectedDate = event.target.value
    const url = new URL(window.location.href)
    url.searchParams.set('date', selectedDate)
    
    // คำนวณ start_date จากวันที่เลือก
    const date = new Date(selectedDate)
    const day = date.getDay()
    const diff = date.getDate() - day
    const startDate = new Date(date.setDate(diff))
    url.searchParams.set('start_date', startDate.toISOString().split('T')[0])

    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
  }

  previousWeek(event) {
    event.preventDefault()
    const startDate = new Date(event.currentTarget.dataset.startDate)
    const newStartDate = new Date(startDate)
    newStartDate.setDate(startDate.getDate() - 7)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    
    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
  }

  nextWeek(event) {
    event.preventDefault()
    const startDate = new Date(event.currentTarget.dataset.startDate)
    const newStartDate = new Date(startDate)
    newStartDate.setDate(startDate.getDate() + 7)
    
    const url = new URL(window.location.href)
    url.searchParams.set('start_date', newStartDate.toISOString().split('T')[0])
    
    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
  }

  select(event) {
    event.preventDefault()
    const url = new URL(event.currentTarget.href)
    
    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
  }
} 