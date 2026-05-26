import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
import zoomPlugin from 'chartjs-plugin-zoom';
Chart.register(...registerables, zoomPlugin);

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
          label: 'BULL数',
          data: this.dataValue,
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      },

      options: {
        plugins: {
          zoom: {
            // スワイプでグラフを移動させる設定
            pan: {
              enabled: true,
              mode: 'x', // 横方向だけ移動可能にする
            },
            // 拡大・縮小の設定
            zoom: {
              wheel: {
                enabled: true, // パソコンのマウスホイールでズーム
              },
              pinch: {
                enabled: true // スマホの指（ピンチアウト・ピンチイン）でズーム
              },
              mode: 'x', // 横方向（時間や回数など）だけズームさせる
            }
          }
        }
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