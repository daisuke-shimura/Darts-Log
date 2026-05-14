import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "targetName", "scoreBox", "roundScore", "roundBox", "currentRate"
  ];
  static values = {
    gameId: Number
  };
  static CRICKET_SEGMENTS = [20, 19, 18, 17, 16, 15, 50];
  static MARK_ICON = {
    1: "one-mark",
    2: "two-mark",
    3: "three-mark"
  }

  connect() {
    console.log("shoot-out controller connected");
    console.log("gameId:", this.gameIdValue);
    this.selected = [];
    this.round = Number(this.element.dataset.round);
    this.currentScore = Number(this.element.dataset.currentScore);
    this.scoreBoxTarget.textContent = this.currentScore;
    this.segmentsStatus = JSON.parse(this.element.dataset.currentStatus);
    this.currentRate = this.reRate();
    this.updateButtons();
    this.currentRoundRow();
    this.setTarget();
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
      score: this.score(Number(hole.dataset.value), hole.dataset.multiplier),
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.setTarget()
    this.render();
    this.updateButtons();
    this.currentScore += front_data.score;
    this.refreshView();
    this.currentRate = this.reRate();
  }

  reRate() {
    const rate = (
      Object.keys(this.segmentsStatus).filter(key => {
        return this.segmentsStatus[key] !== 0;
      }).length + 1
    );

    const currentRate = Math.min(rate, 21);
    this.currentRateTarget.textContent = currentRate;
  
    return currentRate;
  }

  score(segment, multiplier) {
    if (this.segmentsStatus[segment] !== 0) return 0;

    let number;
    let rate;
    if (segment === 50) {
      number = 25;
    } else {
      number = segment;
    }

    if (multiplier === "triple") {
      rate = 3;
    } else if (multiplier === "double") {
      rate = 2;
    } else {
      rate = 1;
    }

    this.segmentsStatus[segment] = number * rate * this.currentRate
    return this.segmentsStatus[segment];
  }

  refreshView() {
    this.scoreBoxTarget.textContent = this.currentScore;
    const roundEl = this.roundScoreTargets[this.round - 1];
    const sumScore = this.sumRoundScore();
    roundEl.classList.remove("text-danger", "text-warning");
    roundEl.textContent = sumScore;
    if (sumScore >= 151) {
      roundEl.classList.add("text-warning");
    } else if (sumScore >= 100) {
      roundEl.classList.add("text-danger");
    }

    Object.keys(this.segmentsStatus).forEach(segment => {
      const closeEl = this.element.querySelector(
        `[data-segment="${segment}"]`
      );
      if (!closeEl) return;
  
      if (this.segmentsStatus[segment] !== 0) {
        closeEl.classList.add("closed-number");
      } else {
        closeEl.classList.remove("closed-number");
      }
    });
  }

  sumRoundScore() {
    return this.selected.reduce((sum, p) => sum + p.score, 0);
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

  setTarget() {
    let targetValue = "";
    let targetName = "";
    const targetKey = Number(
      Object.keys(this.segmentsStatus).find(key => {
        return this.segmentsStatus[key] === 0;
      })
    );

    const targetNumber = targetKey ? Number(targetKey) : null;

    if (1 <= targetNumber && targetNumber <= 20) {
      targetValue = `t${targetNumber}`;
      targetName = `TRIPLE ${targetNumber}`;
    } else {
      targetValue = "bull";
      targetName = "BULL";
    } 

    this.targetInputTarget.value = targetValue;
    this.targetNameTarget.textContent = targetName;
  }

  cancel() {
    if (this.selected.length === 0) return;
    const removed = this.selected.pop();
    if (removed.score !== 0) {
      this.segmentsStatus[removed.segment] = 0;
    }
    this.setTarget();
    this.currentScore -= removed.score;
    this.refreshView();
    this.currentRate = this.reRate();
    this.render();
    this.updateButtons();
  }

  submit() {
    console.log("submit clicked");
    if (this.selected.length === 0) {
      return;
    }

    fetch(`/games/${this.gameIdValue}/shoot_out`, {
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