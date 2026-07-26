import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Calendar controller connected")

    this.popovers = this.element.querySelectorAll(
      '[data-bs-toggle="popover"]'
    )

    this.popovers.forEach(element => {
      new bootstrap.Popover(element)
    })
  }

  disconnect() {
    console.log("Calendar controller disconnected")

    this.popovers?.forEach(element => {
      const popover = bootstrap.Popover.getInstance(element)

      if (popover) {
        popover.dispose()
      }
    })
  }
}
