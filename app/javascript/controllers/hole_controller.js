import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output", "flash"];

  connect() {
    console.log("hole controller connected");
    this.selected = [];
  }

  click(event) {
    const hole = event.currentTarget;

    const front_data = {
      absolute_r: Number(hole.dataset.absolute_r),
      absolute_0: Number(hole.dataset.absolute_0),
      r: Number(hole.dataset.index_r),
      n: Number(hole.dataset.index_n),
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
          this.outputTargets[index].textContent = `${p.name} ${p.value}点, (r, θ) = (${p.absolute_r}, ${p.absolute_0}), (r, n) = (${p.r}, ${p.n})`;
        }
      });
  }

  showMessage(message) {
    const toastEl = document.getElementById("liveToast")
    toastEl.querySelector(".toast-body").textContent = message
    const toast = new bootstrap.Toast(toastEl)
    toast.show()
  }

  submit() {
    console.log("submit clicked");
    const results = this.selected
    fetch("/records", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: results
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === "ok") {
        this.selected = [];
        this.render();
        this.showMessage("保存しました");
      }
    })
    .catch(err => {
      console.error(err)
    });
  }

}