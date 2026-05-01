import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output", "flash", "submitBtn", "cancelBtn", "targetInput"];

  connect() {
    console.log("hole controller connected");
    this.selected = [];
    this.hit = 0;
    this.updateSubmitButton();
    this.updateCancelButton();
  }

  click(event) {
    const hole = event.target.closest(".hole");
    if (!hole) return;

    const target = this.targetInputTarget.value;
    const front_data = {
      absolute_r: Number(hole.dataset.absolute_r),
      absolute_0: Number(hole.dataset.absolute_0),
      r: Number(hole.dataset.index_r),
      n: Number(hole.dataset.index_n),
      value: Number(hole.dataset.value),
      name: hole.dataset.name,
      multiplier: hole.dataset.multiplier,
      target: target
    };

    console.log("front_data:", front_data);

    if (front_data.target === "bull") {
      if (front_data.value === 50) {
        this.hit += 1;
      }
    }
    else if (front_data.target === "undefined") {
    }
    else {
      let hit_number;
      hit_number = front_data.multiplier[0] + front_data.value;
      if (front_data.target === hit_number) {
        this.hit += 1;
      }
    }

    if (this.selected.length >= 3) {
      alert("3つまで！");
      return;
    }

    this.selected.push(front_data);
    this.render();
    this.updateSubmitButton();
    this.updateCancelButton();
  }

  render() {
    this.outputTargets.forEach(el => el.textContent = "");
      this.selected.forEach((p, index) => {
        if (this.outputTargets[index]) {
          let rate;
          if (p.multiplier === "triple") {
            rate = 3;
          } else if (p.multiplier === "double" && p.value !== 50) {
            rate = 2;
          } else {
            rate = 1;
          }
          const html = `${p.name} ${p.value * rate}点<br>(r, θ) = (${p.absolute_r}, ${p.absolute_0})<br>(r, n) = (${p.r}, ${p.n})`;
          this.outputTargets[index].innerHTML = html;
        }
      });
  }

  showMessage(message) {
    const toastEl = document.getElementById("liveToast")
    toastEl.querySelector(".toast-body").textContent = message
    const toast = new bootstrap.Toast(toastEl)
    toast.show()
  }

  updateSubmitButton() {
    this.submitBtnTarget.disabled = this.selected.length === 0;
  }

  updateCancelButton() {
    this.cancelBtnTarget.disabled = this.selected.length === 0;
  }

  submit() {
    if (this.selected.length === 0) {
      return;
    }

    console.log("submit clicked");
    const results = this.selected
    const hit = this.hit;
    fetch("/records", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: results,
        hit: hit
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === "ok") {
        this.selected = [];
        this.hit = 0;
        this.render();
        this.updateSubmitButton();
        this.showMessage("保存しました");
      }
    })
    .catch(err => {
      console.error(err)
    });
  }

  cancel() {
    if (this.selected.length === 0) return;
  
    this.selected.pop();
    this.render();
    this.updateSubmitButton();
    this.updateCancelButton();
  }
}