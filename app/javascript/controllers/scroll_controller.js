import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      const header = document.querySelector("header")
      const height = header?.offsetHeight || 60

      const params = new URLSearchParams(window.location.search)

      if (params.get("scroll") === "calendar") {
        const calendar = document.getElementById("calendar")

        window.scrollTo({
          top: calendar.offsetTop + height,
          behavior: "auto"
        })

        return
      }

      window.scrollTo({
        top: height,
        behavior: "instant"
      })
    })
  }
}
