import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
import zoomPlugin from 'chartjs-plugin-zoom';
Chart.register(...registerables, zoomPlugin);

export default class extends Controller {
  static targets = [
    "canvas",
    "checkbox"
  ]

  static values = {
    labels: Array,
    graphData: Array
  }

  connect() {
    const scales = {}
  
    this.graphDataValue.forEach((graph) => {
      if (!scales[graph.axis]) {
        scales[graph.axis] = {
          type: "linear",
          position: "left",
          title: {
            display: true,
            text: graph.label || ""
          }
        }
      }
    })
  
    this.chart = new Chart(this.canvasTarget, {
      type: "line",
  
      data: {
        labels: this.labelsValue,
  
        datasets: this.graphDataValue.map((graph) => ({
          label: graph.label,
          data: graph.data,
          borderColor: graph.color,
          tension: 0.1,
          yAxisID: graph.axis
        }))
      },
  
      options: {
        responsive: true,
        scales
      }
    })
  }

  toggleGraph() {
    this.checkboxTargets.forEach((checkbox, index) => {
      this.chart.setDatasetVisibility(
        index,
        checkbox.checked
      )
    })

    this.chart.update()
  }

  disconnect() {
    this.chart?.destroy()
  }
}
