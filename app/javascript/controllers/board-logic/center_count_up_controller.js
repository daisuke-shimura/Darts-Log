import { Controller } from "@hotwired/stimulus";

const CENTER_COUNT_UP_SCORE = [
  { max: 16.6, score: 600 },
  { max: 40.0, score: 500 },
  { max: 54.6, score: 480 },
  { max: 65.9, score: 400 },
  { max: 84.8, score: 350 },
  { max: 109.0, score: 200 },
  { max: 130.4, score: 100 },
  { max: 150.2, score: 80 },
  { max: 173.8, score: 70 },
  { max: 196.0, score: 60 },
  { max: 392.6, score: 50 },
  { max: 478.0, score: 0 }
];

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "scoreBox", "roundScore", "roundBox"
  ];
  static values = {
    gameId: Number
  };

  connect() {
    console.log("center-count-up controller connected");
    console.log("gameId:", this.gameIdValue);
    this.selected = [];
    this.round = Number(this.element.dataset.round);;
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
      score: this.score(Number(hole.dataset.absolute_r))
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateButtons();
    this.currentScore += front_data.score;
    this.refreshView();
  }

  score(absolute_r) {
    const result = CENTER_COUNT_UP_SCORE.find(range => absolute_r <= range.max);
    return result ? result.score : 0;
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
    el.textContent = sumScore;
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