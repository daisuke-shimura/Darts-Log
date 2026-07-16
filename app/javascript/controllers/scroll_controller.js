import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      const header = document.querySelector("header")
      const height = header?.offsetHeight || 60

      window.scrollTo({
        top: height,
        behavior: "instant"
      })
    })
  }
}
