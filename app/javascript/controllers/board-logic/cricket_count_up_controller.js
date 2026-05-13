import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "targetName", "scoreBox", "roundScore", "roundBox"
  ];
  static values = {
    gameId: Number
  }
  static CRICKET_SEGMENTS = [20, 19, 18, 17, 16, 15, 50];
  static MARK_ICON = {
    1: "one-mark",
    2: "two-mark",
    3: "three-mark"
  };

  connect() {
    console.log("count-up controller connected");
    console.log("gameId:", this.gameIdValue);
    this.selected = [];
    this.round = Number(this.element.dataset.round);
    this.currentScore = Number(this.element.dataset.currentScore);
    this.scoreBoxTarget.textContent = this.currentScore;
    this.round_marks = 0;
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
    const mark = this.markDefine(Number(hole.dataset.value), hole.dataset.multiplier);
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
      score: this.score(Number(hole.dataset.value), mark),
      mark: mark
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateButtons();
    this.currentScore += front_data.score;
    this.rewriteCurrentMark();
    this.round_marks += front_data.mark;
  }

  markDefine(segment, multiplier) {
    let mark;
    const allow_number = this.constructor.CRICKET_SEGMENTS;

    const validSegment =
      (this.round >= 1 && this.round <= 7 &&
        segment === allow_number[this.round - 1]) ||
      (this.round === 8 &&
        allow_number.includes(segment)) ||
      this.round >= 9;

    if (!validSegment) {
      mark = 0;
    } else if (multiplier === "triple") {
      mark = 3;
    } else if (multiplier === "double") {
      mark = 2;
    } else if (multiplier === "single") {
      mark = 1;
    } else {
      mark = 0;
    }
    return mark;
  }

  score(segment, mark) {
    if (segment === 50) {
      if (mark === 2) {
        return 50;
      } else if (mark === 1) {
        return 25;
      } else {
        return 0;
      }        
    }
    return segment * mark;
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

  rewriteCurrentMark() {
    this.scoreBoxTarget.textContent = this.currentScore;

    const currentRound = this.roundScoreTargets[this.round - 1];
    if (!currentRound) return;

    const spans = currentRound.querySelectorAll("span");
    spans.forEach((span, index) => {
      const dart = this.selected[index];
  
      if (!dart) {
        span.innerHTML = "";
      } else if (dart.mark === 0) {
        span.innerHTML = "-";
      } else {
        span.innerHTML = this.changeMarkIcon(dart.mark);
      }
    });
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

  changeMarkIcon(mark) {
    if (mark <= 0) {
      return "-";
    }
    else {
      const iconName = this.constructor.MARK_ICON[mark];
      return `
        <svg class="cricket-mark-icon">
          <use href="#icon-${iconName}"></use>
        </svg>
      `.trim();
    }
  }

  submit() {
    console.log("submit clicked");
    if (this.selected.length === 0) {
      return;
    }

    fetch(`/games/${this.gameIdValue}/cricket_count_up`, {
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
        this.setTarget();
        this.showMessage("保存しました");
      }
    })
    .catch(err => {
      console.error(err)
    });
  }

  cancel() {
    if (this.selected.length === 0) return;
    const removed = this.selected.pop();
    this.currentScore -= removed.score;
    this.rewriteCurrentMark();
    this.round_marks -= removed.mark;
    this.render();
    this.updateButtons();
  }

  setTarget() {
    let targetValue = "";
    let targetName = "";
    if (this.round >= 1 && this.round <= 6) {
      targetValue = `t${this.constructor.CRICKET_SEGMENTS[this.round - 1]}`;
      targetName = `TRIPLE ${this.constructor.CRICKET_SEGMENTS[this.round - 1]}`;
    } else if (this.round === 7) {
      targetValue = "bull";
      targetName = `BULL`;
    } else if (this.round === 8) {
      targetValue = "t20";
      targetName = `TRIPLE 20`;
    } else {
      targetValue = "bull";
      targetName = `BULL`;
    }

    this.targetInputTarget.value = targetValue;
    this.targetNameTarget.textContent = targetName;
  }

  showMessage(message) {
    const toastEl = document.getElementById("liveToast")
    toastEl.querySelector(".toast-body").textContent = message
    const toast = new bootstrap.Toast(toastEl)
    toast.show()
  }
}