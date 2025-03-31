import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["datePicker"]

  connect() {
    // ตั้งค่าเริ่มต้นเป็นวันปัจจุบัน
    const today = new Date().toISOString().split('T')[0]
    this.datePickerTarget.value = today

    // เพิ่ม event listener สำหรับการเปลี่ยนแปลงค่า
    this.datePickerTarget.addEventListener('change', (e) => {
      this.dateSelected(e)
    })

    // ป้องกันการ render เมื่อ hover
    const preventDefaultEvent = (e) => {
      e.preventDefault()
      e.stopPropagation()
      return false
    }

    // เพิ่ม event listeners สำหรับทุก hover event ให้กับทุก element
    const elements = this.element.querySelectorAll('*')
    elements.forEach(element => {
      element.addEventListener('mouseover', preventDefaultEvent)
      element.addEventListener('mouseenter', preventDefaultEvent)
      element.addEventListener('mouseleave', preventDefaultEvent)
      element.addEventListener('mouseout', preventDefaultEvent)
      element.addEventListener('mousemove', preventDefaultEvent)
    })

    // จัดการการแสดงผลปฏิทิน
    this.datePickerTarget.addEventListener('focus', () => {
      this.datePickerTarget.showPicker()
    })
  }

  dateSelected(event) {
    const selectedDate = event.target.value
    if (!selectedDate) return

    // อัพเดทค่าใน text box
    this.datePickerTarget.value = selectedDate

    // แปลงวันที่เป็นรูปแบบที่ต้องการ (YYYY-MM-DD)
    const date = new Date(selectedDate)
    const formattedDate = date.toISOString().split('T')[0]
    
    // ดึงข้อมูลการจอง
    this.fetchBookings(formattedDate)
  }

  fetchBookings(date) {
    fetch(`/bookings?date=${date}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error fetching bookings:', error)
    })
  }

  openDatePicker() {
    this.datePickerTarget.click()
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
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
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
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
  }

  select(event) {
    event.preventDefault()
    const url = new URL(event.currentTarget.href)
    
    // ส่ง request ด้วย Fetch API
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
  }
} 