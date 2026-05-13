import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "output", "flash", "resultItem", "submitBtn", "cancelBtn", "targetInput",
    "targetName", "roundScore", "roundBox", "marksBox"
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
    console.log("cricket controller connected");
    console.log("gameId:", this.gameIdValue);
    this.marksHistory = [];
    this.selected = [];
    this.round = Number(this.element.dataset.round);
    this.round_marks = 0;
    this.statsJudgeTrigger = false;
    this.clear = false;
    this.currentScore = Number(this.element.dataset.currentScore);
    this.updateButtons();
    this.currentRoundRow();
    this.segmentsStatus = JSON.parse(this.element.dataset.currentScore);
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
      bounce_out: false
    };

    console.log("front_data:", front_data);

    this.selected.push(front_data);
    this.render();
    this.updateButtons();
    this.rewriteCurrentMark(front_data.segment, front_data.multiplier);
    this.setTarget();
    this.isClear();
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
          const html = `${p.name}<br>(r, θ) = (${p.absolute_r}, ${p.absolute_0})`;
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

  rewriteCurrentMark(segment, multiplier) {
    let mark;
    if (this.constructor.CRICKET_SEGMENTS.includes(Number(segment))) {
      if (multiplier === "triple") {
        mark = 3;
      } else if (multiplier === "double") {
        mark = 2;
      } else {
        mark = 1;
      }
      const beforeMark = this.segmentsStatus[segment];
      if (beforeMark >= 3) {
        mark = 0;
      } else {
        mark = Math.min(mark, 3 - beforeMark);
      }
      this.marksHistory.push({ segment: segment, amount: mark });
      this.segmentsStatus[segment] += mark;
      const targetElement = this.marksBoxTarget.querySelector(`[data-cricketrow="${segment}"]`);
      if (targetElement) {
        targetElement.innerHTML = this.changeMarkIcon(this.segmentsStatus[segment]);
      }
    } else {
      mark = 0;
    }
    const currentRound = this.roundScoreTargets[this.round - 1];
    if (currentRound) {
      const spans = currentRound.querySelectorAll("span");
      spans[(this.selected.length) - 1].innerHTML = this.changeMarkIcon(mark);
    }
    this.round_marks += mark;
  }

  revertCurrentMark() {
    if (!this.marksHistory || this.marksHistory.length === 0) return;
    const lastAction = this.marksHistory.pop();
    const segment = lastAction.segment;
    const reduced = lastAction.amount;
    this.segmentsStatus[segment] -= reduced;
    this.round_marks -= reduced;
    const targetElement = this.marksBoxTarget.querySelector(`[data-cricketrow="${segment}"]`);
    if (targetElement) {
      targetElement.innerHTML = this.changeMarkIcon(this.segmentsStatus[segment]);
    }
    const currentRound = this.roundScoreTargets[this.round - 1];
    if (currentRound) {
      const spans = currentRound.querySelectorAll("span");
      if (spans[this.selected.length]) {
        spans[this.selected.length].innerHTML = "";
      }
    }
  }

  submit() {
    if (this.selected.length === 0) {
      return;
    }

    console.log("submit clicked");
    fetch(`/games/${this.gameIdValue}/cricket`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        results: this.selected,
        mark: this.round_marks,
        stats_judge: this.statsJudgeTrigger,
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
        this.clear = false;
        this.element.querySelector(".board").classList.remove("clear");
        this.round ++;
        this.exceedRoundRow();
        this.round_marks = 0;
        this.marksHistory = [];
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

  cancel() {
    if (this.selected.length === 0) return;
    this.clear = false;
    this.element.querySelector(".board").classList.remove("clear");
    this.selected.pop();
    this.revertCurrentMark();
    this.render();
    this.updateButtons();
    this.setTarget();
    this.isClear();
  }

  exceedRoundRow() {
    if (this.round === this.roundScoreTargets.length) {
      const html = `
      <div class="d-flex">
        <span class="ps-1 round-label">R${this.round + 1}</span>
        <span class="round-mark" data-board-logic--cricket-target="roundScore">
          <span></span>
          <span></span>
          <span></span>
        </span>
      </div>
    `;
    this.roundBoxTarget.insertAdjacentHTML("beforeend", html);
    this.roundBoxTarget.scrollTop = this.roundBoxTarget.scrollHeight;
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

  isClear() {
    this.statsJudgeTrigger = this.constructor.CRICKET_SEGMENTS
      .filter(segment => segment !== 50)
      .every(segment => {
        return this.segmentsStatus[segment] >= 3;
    });
    this.clear = this.constructor.CRICKET_SEGMENTS.every(segment => {
      return this.segmentsStatus[segment] >= 3;
    });
  
    if (this.clear) {
      this.element.querySelector(".board").classList.add("clear");
    } else {
      this.element.querySelector(".board").classList.remove("clear");
    }
  }

  setTarget() {
    const targetSegment = this.constructor.CRICKET_SEGMENTS.find(segment => {
      return this.segmentsStatus[segment] < 3;
    });

    let targetValue = "";
    let targetName = "";

    if ([20, 19, 18, 17, 16, 15].includes(targetSegment)) {
      targetValue = `t${targetSegment}`;
      targetName = `TRIPLE ${targetSegment}`;
    } else {
      targetValue = "bull";
      targetName = "BULL";
    }
  
    this.targetInputTarget.value = targetValue;
    this.targetNameTarget.textContent = targetName;
  }
}
