import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "tags", "color", "hiddenInputs"]

  static values = {
    targets: Array,
    colors: Array
  }

  connect() {
    console.log("Filter controller connected")
    this.targetsValue.forEach((target, index) => {
      const color = this.colorsValue[index] || "#ff0000"
  
      this.createTag(target, color)
    })
  }


  addTarget() {
    const value = this.selectTarget.value
    const color = this.colorTarget.value || "#ff0000"

    if (this.hiddenInputsTarget.querySelector(
      `input[value="${value}"]`
    )) return

    this.createTag(value, color)
  }


  createTag(value, color) {
    const tag = document.createElement("div")
    const contrast = this.designTagBtn(color);
    tag.style.backgroundColor = color
    tag.className = `badge d-flex align-items-center gap-2 ${contrast.text}`
    tag.innerHTML = `
      <span>${value.toUpperCase()}</span>
      <button
        type="button"
        class="btn-close ${contrast.btn}"
        aria-label="Remove"
      ></button>
    `

    const wrapper = document.createElement("div")

    wrapper.innerHTML = `
      <input type="hidden" name="targets[]" value="${value}">
      <input type="hidden" name="colors[]" value="${color}">
    `
  
    tag.querySelector("button")
      .addEventListener("click", () => {
        tag.remove()
        wrapper.remove()
      })

    this.tagsTarget.appendChild(tag)
    this.hiddenInputsTarget.appendChild(wrapper)
  }


  designTagBtn(color) {
    if (!color || !color.startsWith('#')) {
      return { text: 'text-white', btn: 'btn-close-white' };
    }

    const hex = color.replace('#', '');
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);

    const brightness = (r * 299 + g * 587 + b * 114) / 1000;

    return brightness < 128
      ? { text: 'text-white', btn: 'btn-close-white' }
      : { text: 'text-dark', btn: '' };
    }
}
