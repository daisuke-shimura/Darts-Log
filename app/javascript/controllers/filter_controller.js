import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "select",
    "tags",
    "hiddenInputs"
  ]

  connect() {
    console.log("Filter controller connected")
  }

  addTarget() {
    const value = this.selectTarget.value

    if (this.hiddenInputsTarget.querySelector(
      `input[value="${value}"]`
    )) return

    const tag = document.createElement("div")
    tag.className =
      "badge bg-primary d-flex align-items-center gap-2"

    tag.innerHTML = `
      <span>${value.toUpperCase()}</span>
      <button
        type="button"
        class="btn-close btn-close-white"
        aria-label="Remove"
      ></button>
    `

    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "targets[]"
    input.value = value

    tag.querySelector("button")
      .addEventListener("click", () => {
        tag.remove()
        input.remove()
      })

    this.tagsTarget.appendChild(tag)
    this.hiddenInputsTarget.appendChild(input)
  }
}
