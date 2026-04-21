import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("result controller connected");

    this.form = document.getElementById("fixedForm");
    this.updatePosition = this.updatePosition.bind(this);
    this.updatePosition();

    if (window.visualViewport) {
      window.visualViewport.addEventListener("resize", this.updatePosition);
      window.visualViewport.addEventListener("scroll", this.updatePosition);
    }
  }

  disconnect() {
    if (window.visualViewport) {
      window.visualViewport.removeEventListener("resize", this.updatePosition);
      window.visualViewport.removeEventListener("scroll", this.updatePosition);
    }
  }

  updatePosition() {
    const TopSpace = 40;
    const vv = window.visualViewport;
    const scale = 1/vv.scale;

    const x = vv.offsetLeft / scale;
    const y = (vv.offsetTop / scale) + TopSpace;

    this.form.style.transform = `
      scale(${scale})
      translate(${x}px, ${y}px)
    `;
  }
}
