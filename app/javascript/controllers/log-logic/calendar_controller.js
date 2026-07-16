import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Calendar controller connected")
    const popovers = this.element.querySelectorAll(
      '[data-bs-toggle="popover"]'
    )
  
    popovers.forEach(element => {
      new bootstrap.Popover(element)
    })
  }
}
