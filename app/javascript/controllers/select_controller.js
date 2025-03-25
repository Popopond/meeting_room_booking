import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("change", this.handleChange.bind(this))
  }

  handleChange(event) {
    const select = event.target
    const option = select.options[select.selectedIndex]
    if (option) {
      const userId = option.value
      const username = option.text
      const avatar = option.dataset.avatar
      
      // สร้าง custom option HTML
      const customOption = document.createElement("div")
      customOption.className = "flex items-center space-x-2"
      customOption.innerHTML = `
        <div class="w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center">
          ${avatar ? 
            `<img src="${avatar}" class="w-full h-full rounded-full object-cover">` :
            `<span class="text-gray-500 text-xs">${username[0].toUpperCase()}</span>`
          }
        </div>
        <span>${username}</span>
      `
      
      // แทนที่ option เดิมด้วย custom option
      option.innerHTML = customOption.innerHTML
    }
  }
} 