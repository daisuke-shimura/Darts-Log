import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn",
    "targetInput", "targetName", "scoreBox", "roundScore", "roundBox"
  ];
  static values = {
    gameId: Number,
    options: Number,
    targetLabels: Object
  }

  connect() {
    console.log("zero-one controller connected");
    console.log("gameId:", this.gameIdValue);
    console.log("options:", this.optionsValue);
    this.selected = [];
    this.round = Number(this.element.dataset.round);
    this.bust = false;
    this.clear = false;
    this.currentScore = Number(this.element.dataset.currentScore);
    this.scoreBoxTarget.textContent = this.currentScore;
    this.updateButtons();
    this.currentRoundRow();
  }

  click(event) {
    const hole = event.target.closest(".hole");
    if (!hole) return;
    if (this.bust) {
      alert("BUSTしてます！\n確定ボタンを押してください");
      return;
    }

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
    this.rewriteCurrentScore(front_data.score);
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

  rewriteCurrentScore(score) {
    this.currentScore -= score;
    if (this.currentScore < 0) {
      this.bust = true;
      this.element.querySelector(".board").classList.add("bust");
    } else if (this.currentScore === 0) {
      this.clear = true;
      this.element.querySelector(".board").classList.add("clear");
    }
    this.refreshView();
  }

  submit() {
    if (this.selected.length === 0) {
      return;
    }

    console.log("submit clicked");
    fetch(`/games/${this.gameIdValue}/zero_one`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: this.selected,
        bust: this.bust,
        clear: this.clear
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === "ok") {
        if (data.redirect_url) {
          window.location.href = data.redirect_url;
          return;
        }
        this.handleBust();
        this.round++;
        this.bust = false;
        this.clear = false;
        this.element.querySelector(".board").classList.remove("bust");
        this.element.querySelector(".board").classList.remove("clear");
        this.selected = [];
        this.render();
        this.updateButtons();
        this.currentRoundRow();
        this.exceedRoundRow();
        this.showMessage("保存しました");
      }
    })
    .catch(err => {
      console.error(err)
    });
  }

  cancel() {
    if (this.selected.length === 0) return;
    this.bust = false;
    this.element.querySelector(".board").classList.remove("bust");
    this.clear = false;
    this.element.querySelector(".board").classList.remove("clear");
    const removed = this.selected.pop();
    this.currentScore += removed.score;
    this.refreshView();
    this.render();
    this.updateButtons();
  }

  sumRoundScore() {
    return this.selected.reduce((sum, p) => sum + p.score, 0);
  }

  exceedRoundRow() {
    if (this.round !== this.roundScoreTargets.length) return;
      const html = `
        <div class="d-flex">
          <span class="ps-1 round-label">R${this.round + 1}</span>
          <span class="pe-2 round-score" data-board-logic--zero-one-target="roundScore">-</span>
        </div>
      `;
      this.roundBoxTarget.insertAdjacentHTML("beforeend", html);
      this.roundBoxTarget.scrollTop = this.roundBoxTarget.scrollHeight;
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

  refreshView() {
    this.scoreBoxTarget.textContent = this.currentScore;
    const el = this.roundScoreTargets[this.round - 1];
    const sumScore = this.sumRoundScore();
    el.classList.remove("text-danger", "text-warning", "text-primary");
  
    if (this.bust) {
      el.textContent = "BUST";
      el.classList.add("text-primary");
    } else {
      el.textContent = sumScore;
      if (sumScore >= 151) {
        el.classList.add("text-warning");
      } else if (sumScore >= 100) {
        el.classList.add("text-danger");
      }
    }
  }

  handleBust() {
    if (this.bust === false) return;
    const el = this.roundScoreTargets[this.round - 1];
    el.classList.remove("text-danger", "text-warning", "text-primary");
    this.currentScore += this.sumRoundScore();
    this.scoreBoxTarget.textContent = this.currentScore;
    el.classList.add("text-primary");
    el.textContent = "BUST";
    //BUST時にターゲットを戻す
    const firstDart = this.selected[0];
    this.targetInputTarget.value = firstDart.target;
    this.targetNameTarget.textContent = this.targetLabelsValue[firstDart.target];
  }
}
