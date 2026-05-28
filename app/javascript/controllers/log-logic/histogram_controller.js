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
      type: 'bar',
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: '本',
          data: this.dataValue,
          backgroundColor: 'rgba(54, 162, 235, 0.6)',
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 1,
          barPercentage: 1.0,
          categoryPercentage: 1.0
        }]
      },
      options: {
        scales: {
          x: { grid: { display: false }},
          y: { beginAtZero: true }
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