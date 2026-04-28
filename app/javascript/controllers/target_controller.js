import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["name"]

  connect() {
    console.log("target controller connected");
  }

  select(event) {
    // const value = event.currentTarget.dataset.value
    const targetEl = event.target.closest(".target");
    // segment以外クリック無視
    if (!targetEl) return;

    const value = targetEl.dataset.value;
    const name = targetEl.dataset.name;

    console.log("clicked", value, name);

    // hidden更新（hole_controllerと共有）
    document.querySelector('[data-hole-target="targetInput"]').value = value;

    // 表示更新（任意）
    this.nameTarget.textContent = name;

    // モーダル閉じる ←ここだけJS必要
    const modalEl = document.getElementById("targetModal");
    const modal = bootstrap.Modal.getInstance(modalEl);
    document.activeElement.blur();
    modal.hide();
  
    // window.location.href = `/records?target=${value}&target_name=${encodeURIComponent(name)}`
  }
}
