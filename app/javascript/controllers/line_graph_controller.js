import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

export default class extends Controller {
  // HTMLから受け取るデータの型を定義（自動でJSONパースされます）
  static values = {
    labels: Array,
    data: Array
  }

  // HTML(canvas)が画面に表示された瞬間に実行される
  connect() {
    this.chart = new Chart(this.element, {
      type: 'line',
      data: {
        labels: this.labelsValue, // static values で定義したものを使用
        datasets: [{
          label: '月別売上',
          data: this.dataValue,
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      }
    });
  }

  // 画面遷移などでcanvasが消えた瞬間に実行される（超重要！）
  disconnect() {
    if (this.chart) {
      this.chart.destroy();
    }
  }
}