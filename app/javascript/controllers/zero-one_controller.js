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
    this.round = Number(this.element.dataset.round);;
    this.bust = false;
    this.clear = false;
    this.currentScore = Number(this.element.dataset.currentScore);
    this.scoreBoxTarget.textContent = this.currentScore;
    this.updateSubmitButton();
    this.updateCancelButton();
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
      score: this.score(Number(hole.dataset.value), hole.dataset.multiplier)
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateSubmitButton();
    this.updateCancelButton();
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

  render() {
    this.outputTargets.forEach(el => el.textContent = "");
      this.selected.forEach((p, index) => {
        if (this.outputTargets[index]) {
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

  rewriteCurrentScore(score) {
    this.currentScore -= score;
    this.scoreBoxTarget.textContent = this.currentScore
    if (this.currentScore < 0) {
      this.bust = true;
      this.element.querySelector(".board").classList.add("bust");
    } else if (this.currentScore === 0) {
      this.clear = true;
      this.element.querySelector(".board").classList.add("clear");
    }
  }

  submit() {
    if (this.selected.length === 0) {
      return;
    }

    console.log("submit clicked");
    const sum_score = this.sumRoundScore();
    const results = this.selected
    fetch(`/games/${this.gameIdValue}/zero_one`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: results,
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
        this.zeroOne(sum_score);
        this.bust = false;
        this.clear = false;
        this.element.querySelector(".board").classList.remove("bust");
        this.element.querySelector(".board").classList.remove("clear");
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
    this.bust = false;
    this.element.querySelector(".board").classList.remove("bust");
    this.clear = false;
    this.element.querySelector(".board").classList.remove("clear");
    const removed = this.selected.pop();
    this.currentScore += removed.score;
    this.scoreBoxTarget.textContent = this.currentScore;
    this.render();
    this.updateSubmitButton();
    this.updateCancelButton();
  }

  sumRoundScore() {
    return this.selected.reduce((sum, p) => sum + p.score, 0);
  }

  zeroOne(sum_score) {
    let colorClass = "";
    let displayText = "";

    const el = this.roundScoreTargets[this.round - 1];
    el.classList.remove("text-danger", "text-warning", "text-primary");

    if (this.bust) {
      this.currentScore += sum_score;
      this.scoreBoxTarget.textContent = this.currentScore;
      colorClass = "text-primary";
      displayText = "BUST";
    } else {
      if (sum_score >= 151) {
        colorClass = "text-warning";
      } else if (sum_score >= 100) {
        colorClass = "text-danger";
      }
      displayText = sum_score;
    }
    if (colorClass) el.classList.add(colorClass);
    el.textContent = displayText;
  
    if (this.round === this.roundScoreTargets.length) {
      this.exceedRoundRow();
    }
  
    this.round++;
  }

  exceedRoundRow() {
    const html = `
      <div class="d-flex">
        <span class="ps-1 round-label">R${this.round + 1}</span>
        <span class="pe-2 round-score" data-zero-one-target="roundScore">-</span>
      </div>
    `;
    this.roundBoxTarget.insertAdjacentHTML("beforeend", html);
    this.roundBoxTarget.scrollTop = this.roundBoxTarget.scrollHeight;
  }
}
