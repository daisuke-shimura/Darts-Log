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
          label: 'Rayleigh Plot',
          data: this.dataValue,
          borderColor: 'rgba(255, 159, 64, 1)',
          borderWidth: 2,
          pointRadius: 3,
          pointHoverRadius: 5,
          tension: 0
        }]
      },

      options: {
        responsive: true,

        plugins: {
          legend: {
            display: true
          }
        },

        scales: {
          x: {
            title: {
              display: true,
              text: 'r²'
            },
            grid: {
              display: false
            }
          },
          y: {
            title: {
              display: true,
              text: '-ln(1 - F(r))'
            },
            beginAtZero: true
          }
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
