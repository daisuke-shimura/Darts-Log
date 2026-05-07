import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["name"]

  connect() {
    console.log("target controller connected");
  }

  select(event) {
    const targetEl = event.target.closest(".target");
    if (!targetEl) return;
  
    const value = targetEl.dataset.value;
    const name = targetEl.dataset.name;
  
    console.log("clicked", value, name);
  
    const selector = this.element.dataset.targetSelector;
    const input = document.querySelector(selector);
  
    if (input) {
      input.value = value;
    }
  
    this.nameTarget.textContent = name;
  
    const modalEl = document.getElementById("targetModal");
    const modal = bootstrap.Modal.getInstance(modalEl);
  
    document.activeElement.blur();
    modal.hide();
  }
}
