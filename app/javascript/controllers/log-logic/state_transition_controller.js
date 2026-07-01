import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("state_transition controller connected");
  }

  toggle(event) {
    const markerId = event.currentTarget.dataset.markerId

    const elements = this.element.querySelectorAll(
      `.transition-${markerId}`
    )

    const hidden = elements.length > 0 && elements[0].style.display === "none"

    elements.forEach((element) => {
      element.style.display = hidden ? "" : "none"
    })

    event.currentTarget.classList.toggle("disabled")
  }
}
