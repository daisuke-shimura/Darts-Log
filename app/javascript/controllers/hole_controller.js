import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output"];

  connect() {
    console.log("hole controller connected");
    this.selected = [];
  }

  click(event) {
    const hole = event.currentTarget;

    const front_data = {
      n: Number(hole.dataset.n),
      absolute_r: Number(hole.dataset.absolute_r),
      absolute_0: Number(hole.dataset.absolute_0),
      x: Number(hole.dataset.x),
      y: Number(hole.dataset.y),
      value: Number(hole.dataset.value),
      name: hole.dataset.name,
      multiplier: hole.dataset.multiplier,
    };

    console.log("front_data:", front_data);

    // 3つ制限
    if (this.selected.length >= 3) {
      alert("3つまで！");
      return;
    }

    this.selected.push(front_data);
    this.render();
  }

  render() {
    this.outputTargets.forEach(el => el.textContent = "");

      this.selected.forEach((p, index) => {
        if (this.outputTargets[index]) {
          this.outputTargets[index].textContent = `${p.name}（${p.value}点, (r, θ) = (${p.absolute_r}, ${p.absolute_0}), (x, y) = (${p.x}, ${p.y})`;
        }
      });
  }

}