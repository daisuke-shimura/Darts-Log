import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "scoreBox", "roundScore", "roundBox"
  ];
  static values = {
    gameId: Number
  }

  connect() {
    console.log("count-up controller connected");
    console.log("gameId:", this.gameIdValue);
    this.selected = [];
    this.round = Number(this.element.dataset.round);
    this.currentScore = Number(this.element.dataset.currentScore);
    this.scoreBoxTarget.textContent = this.currentScore;
    this.updateButtons();
    this.currentRoundRow();
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
      bounce_out: false,
      score: this.score(Number(hole.dataset.value), hole.dataset.multiplier)
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateButtons();
    this.currentScore += front_data.score;
    this.refreshView();
  }

  score(segment, multiplier) {
    let rate;
    if (multiplier === "triple") {
      rate = 3;
    } else if (multiplier === "double" && segment !== 50) {
      rate = 2;
    } else {
      rate = 1;
    }
    return segment * rate;
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
        const html = `${p.name} ${p.score}点<br>(r, θ) = (${p.absolute_r}, ${p.absolute_0})`;
        this.outputTargets[index].innerHTML = html;
        if (p.bounce_out) {
          this.resultItemTargets[index].classList.add("bounce-out");
        }
      }
    });
  }

  updateButtons() {
    const disabled = this.selected.length === 0;
    this.submitBtnTarget.disabled = disabled;
    this.cancelBtnTarget.disabled = disabled;
  }

  refreshView() {
    this.scoreBoxTarget.textContent = this.currentScore;
    const el = this.roundScoreTargets[this.round - 1];
    const sumScore = this.sumRoundScore();
    el.classList.remove("text-danger", "text-warning");
    el.textContent = sumScore;
    if (sumScore >= 151) {
      el.classList.add("text-warning");
    } else if (sumScore >= 100) {
      el.classList.add("text-danger");
    }
  }

  currentRoundRow() {
    const labels = this.roundBoxTarget.querySelectorAll(".round-label");
    labels.forEach(label => {
      label.classList.remove("current-round");
    });
    const currentLabel = labels[this.round - 1];
    if (currentLabel) {
      console.log("current round:", this.round);
      currentLabel.classList.add("current-round");
    }
  }

  sumRoundScore() {
    return this.selected.reduce((sum, p) => sum + p.score, 0);
  }

  cancel() {
    if (this.selected.length === 0) return;
    const removed = this.selected.pop();
    this.currentScore -= removed.score;
    this.refreshView();
    this.render();
    this.updateButtons();
  }

  submit() {
    console.log("submit clicked");
    if (this.selected.length === 0) {
      return;
    }

    fetch(`/games/${this.gameIdValue}/count_up`, {
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
        if (data.redirect_url) {
          window.location.href = data.redirect_url;
          return;
        }
        this.round++;
        this.selected = [];
        this.render();
        this.updateButtons();
        this.currentRoundRow();
        this.showMessage("保存しました");
      }
    })
    .catch(err => {
      console.error(err)
    });
  }

  showMessage(message) {
    const toastEl = document.getElementById("liveToast")
    toastEl.querySelector(".toast-body").textContent = message
    const toast = new bootstrap.Toast(toastEl)
    toast.show()
  }
}