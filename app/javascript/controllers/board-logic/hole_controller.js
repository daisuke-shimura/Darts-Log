import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput", "roundNumber"];

  connect() {
    console.log("hole controller connected");
    this.selected = [];
    this.roundCount = 0;
    this.roundNumberTarget.textContent = `${this.roundCount}回`;
    this.updateButtons();
  }

  click(event) {
    const hole = event.target.closest(".hole");
    if (!hole) return;

    if (this.selected.length >= 3) {
      alert("3つまで！");
      return;
    }

    const target = this.targetInputTarget.value;
    const front_data = {
      absolute_r: Number(hole.dataset.absolute_r),
      absolute_0: Number(hole.dataset.absolute_0),
      r: Number(hole.dataset.index_r),
      n: Number(hole.dataset.index_n),
      segment: Number(hole.dataset.value),
      name: hole.dataset.name,
      multiplier: hole.dataset.multiplier,
      target: target,
      bounce_out: false
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateButtons();
  }

  toggleBounce(event) {
    const index = this.outputTargets.indexOf(event.currentTarget);
    if (index === -1) return;
    if (!this.selected[index]) return;
    this.selected[index].bounce_out = !this.selected[index].bounce_out;
    this.render();
  }

  render() {
    this.outputTargets.forEach(el => el.textContent = "");
      this.resultItemTargets.forEach(el => {
        el.classList.remove("bounce-out");
      });

      this.selected.forEach((p, index) => {
        if (this.outputTargets[index]) {
          let rate;
          if (p.multiplier === "triple") {
            rate = 3;
          } else if (p.multiplier === "double" && p.segment !== 50) {
            rate = 2;
          } else {
            rate = 1;
          }
          const html = `${p.name} ${p.segment * rate}点<br>(r, θ) = (${p.absolute_r}, ${p.absolute_0})`;
          this.outputTargets[index].innerHTML = html;
          if (p.bounce_out) {
            this.resultItemTargets[index].classList.add("bounce-out");
          }
        }
      });
  }

  showMessage(message) {
    const toastEl = document.getElementById("liveToast")
    toastEl.querySelector(".toast-body").textContent = message
    const toast = new bootstrap.Toast(toastEl)
    toast.show()
  }

  updateButtons() {
    const disabled = this.selected.length === 0;
    this.submitBtnTarget.disabled = disabled;
    this.cancelBtnTarget.disabled = disabled;
  }

  submit() {
    if (this.selected.length === 0) {
      return;
    }

    console.log("submit clicked");
    fetch("/records", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: this.selected
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === "ok") {
        this.selected = [];
        this.render();
        this.updateButtons();
        this.showMessage("保存しました");
        this.roundCount += 1;
        this.roundNumberTarget.textContent = `${this.roundCount}回`;
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
    this.updateButtons();
  }
}