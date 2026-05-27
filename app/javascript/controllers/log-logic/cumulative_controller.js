import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

export default class extends Controller {
  static values = {
    labels: Array,
    data: Array
  }

  connect() {
    this.chart = new Chart(this.element, {
      type: 'line',
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: '確率',
          data: this.dataValue,
          borderColor: 'rgba(255, 99, 132, 1)',
          borderWidth: 2,
          pointRadius: 0,
          tension: 0.1,
          stepped: true
        }]
      },
      options: {
        scales: {
          x: { grid: { display: false }},
          y: { min: 0, max: 1 }
        }
      }
    });
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy();
    }
  }
}
