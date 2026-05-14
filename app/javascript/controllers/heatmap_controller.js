import { Controller } from "@hotwired/stimulus"
import h337 from "heatmap.js"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { points: Array }

  connect() {
    if (!this.hasCanvasTarget) return;

    // ブラウザがレイアウト計算を終えるのを一瞬待ってから実行する
    requestAnimationFrame(() => {
      this.drawHeatmap();
    });
  }

  drawHeatmap() {
    const wrapper = this.element;
    // getBoundingClientRect().width を使うと小数点まで正確に取れます
    const currentWidth = wrapper.getBoundingClientRect().width;

    if (currentWidth === 0) return;

    // ログで 500 になっているか確認
    console.log("Current Width for Calculation:", currentWidth);

    const heatmapInstance = h337.create({
      container: this.canvasTarget,
      radius: 30, // 500pxに対しては30くらいがちょうどいいです
      maxOpacity: 0.6,
      minOpacity: 0.1,
      blur: 0.8
    });

    const rawData = this.pointsValue;
    // 1000px基準のデザインに対する現在の倍率
    const scale = currentWidth / 1000.0;

    const scaledPoints = rawData.map(point => ({
      x: Math.round(point.x * scale),
      y: Math.round(point.y * scale),
      value: point.value || 1
    }));

    heatmapInstance.setData({
      max: 2,
      data: scaledPoints
    });
  }
}