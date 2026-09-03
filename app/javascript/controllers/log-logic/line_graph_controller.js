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
    this.keydownHandler = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.keydownHandler)
    
    const scales = {}
    this.graphDataValue.forEach((graph) => {
      if (!scales[graph.axis]) {
        const darkenColor = this.darkenColor(graph.color)
        scales[graph.axis] = {
          type: "linear",
          position: "left",
          border: {
            color: darkenColor
          },
          ticks: {
            color: darkenColor
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
      
        scales,
      
        plugins: {
          zoom: {
            pan: {
              enabled: true,
              mode: "x"
            },
      
            zoom: {
              wheel: {
                enabled: true,
                speed: 0.05
              },
      
              pinch: {
                enabled: true
              },
      
              mode: "x"
            }
          }
        }
      }
    })
  }

  toggleGraph() {
    this.checkboxTargets.forEach((checkbox, index) => {
      const dataset = this.chart.data.datasets[index]
      this.chart.setDatasetVisibility(
        index,
        checkbox.checked
      )
      this.chart.options.scales[dataset.yAxisID].display = checkbox.checked
    })
    this.chart.update()
  }

  darkenColor(color) {
    const amount = 0.7
    const [r, g, b] = color.match(/\d+/g).map(Number)
  
    return `rgb(
      ${Math.round(r * amount)},
      ${Math.round(g * amount)},
      ${Math.round(b * amount)}
    )`
  }

  handleKeydown(event) {
    if (
      event.target.tagName === "INPUT" ||
      event.target.tagName === "TEXTAREA"
    ) {
      return
    }
  
    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.chart.pan({ x: -50 })
        break
  
      case "ArrowRight":
        event.preventDefault()
        this.chart.pan({ x: 50 })
        break
  
      case "ArrowUp":
        event.preventDefault()
        this.chart.zoom(1.1)
        break
  
      case "ArrowDown":
        event.preventDefault()
        this.chart.zoom(0.9)
        break
  
      case "r":
      case "R":
        this.chart.resetZoom()
        break
    }
  }

  disconnect() {
    window.removeEventListener("keydown", this.keydownHandler)
    this.chart?.destroy()
  }
}
