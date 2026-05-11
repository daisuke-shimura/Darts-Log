import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "scoreBox", "roundScore", "roundBox"
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
    this.rewriteCurrentMark(front_data.segment, front_data.multiplier);
  }

  score(segment, multiplier) {
    const allow_number = this.constructor.CRICKET_SEGMENTS;

    if (this.round >= 1 && this.round <= 7) {
      if (segment !== allow_number[this.round - 1]) return 0;
    } else if (this.round === 8) {
      if (!allow_number.includes(segment)) return 0;
    } else {
      return 0;
    }

    if (segment === 50) {
      if (multiplier === "double") {
        return 50;
      } else {
        return 25;
      }
    } else {
      let rate;
      if (multiplier === "triple") {
        rate = 3;
      } else if (multiplier === "double") {
        rate = 2;
      } else {
        rate = 1;
      }
      return segment * rate;
    }
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

  rewriteCurrentMark(segment, multiplier) {
    this.scoreBoxTarget.textContent = this.currentScore;
    let mark;
    if (this.constructor.CRICKET_SEGMENTS.includes(Number(segment))) {
      if (multiplier === "triple") {
        mark = 3;
      } else if (multiplier === "double") {
        mark = 2;
      } else {
        mark = 1;
      }

      const targetElement = this.marksBoxTarget.querySelector(`[data-cricketrow="${segment}"]`);
      if (targetElement) {
        targetElement.innerHTML = this.changeMarkIcon(this.segmentsStatus[segment]);
      }
    } else {
      mark = 0;
    }
    const currentRoundRow = this.roundScoreTargets[this.round - 1];
    if (currentRoundRow) {
      const spans = currentRoundRow.querySelectorAll("span");
      spans[(this.selected.length) - 1].innerHTML = this.changeMarkIcon(mark);
    }
    this.round_marks += mark;
  }
}