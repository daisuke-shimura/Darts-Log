import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output", "flash", "submitBtn", "cancelBtn", "targetInput", "scoreBox", "roundScore", "roundBox"];
  static values = {
    gameId: Number
  }

  connect() {
    console.log("zero-one controller connected");
    console.log("gameId:", this.gameIdValue);
    this.selected = [];
    this.round = 1;
    this.currentScore = Number(this.element.dataset.startScore);
    this.updateSubmitButton();
    this.updateCancelButton();
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
      score: null
    };

    console.log("front_data:", front_data);

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
          } else if (p.multiplier === "double" && p.segment !== 50) {
            rate = 2;
          } else {
            rate = 1;
          }
          p.score = p.segment * rate;
          const html = `${p.name} ${p.score}点<br>(r, θ) = (${p.absolute_r}, ${p.absolute_0})<br>(r, n) = (${p.r}, ${p.n})`;
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
    fetch(`/games/${this.gameIdValue}/zero_one`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: results,
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === "ok") {
        this.zeroOne();
        this.selected = [];
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

  zeroOne() {
    let sum_score = 0;
    this.selected.forEach(p => {
      sum_score += p.score;
    });

    this.currentScore -= sum_score;
    this.scoreBoxTarget.textContent = this.currentScore;

    const el = this.roundScoreTargets[this.round - 1];

    el.classList.remove("text-danger", "text-warning");
    if (sum_score >= 100 && sum_score <= 150) {
      el.classList.add("text-danger");
    } else if (sum_score > 150) {
      el.classList.add("text-warning");
    }
    el.textContent = sum_score;

    if (this.round === this.roundScoreTargets.length) {
      const html = `
        <div class="d-flex">
          <span class="ps-1 round-label">R${this.round + 1}</span>
          <span class="pe-3 round-score" data-zero-one-target="roundScore">-</span>
        </div>
      `;
      this.roundBoxTarget.insertAdjacentHTML("beforeend", html);
      this.roundBoxTarget.scrollTop = this.roundBoxTarget.scrollHeight;
    }
  
    this.round++;
  }
}
