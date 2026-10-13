import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"
import zoomPlugin from "chartjs-plugin-zoom"

Chart.register(...registerables, zoomPlugin)

export default class extends Controller {
  static targets = ["canvas", "select"]
  static values = { graphData: Array }

  connect() {
    this.keydownHandler = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.keydownHandler)

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        datasets: []
      },
      options: {
        responsive: true,
        parsing: false,
        scales: {
          x: {
            type: "linear",
            title: {
              display: true,
              text: "値"
            }
          },
          y: {
            min: 0,
            max: 1,
            ticks: {
              callback: (value) => `${value * 100}%`
            },
            title: {
              display: true,
              text: "累積割合"
            }
          }
        },
        plugins: {
          legend: {
            display: true
          },
          zoom: {
            limits: {
              x: { min: 0, max: 'original' }
            },
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

    this.changeGraph()
  }

  changeGraph() {
    if (!this.chart) return
  
    const selected = this.selectTargets.find(radio => radio.checked)
    if (!selected) return
  
    const graph = this.graphDataValue[Number(selected.value)]
    if (!graph) return
  
    this.chart.data.datasets = [{
      label: graph.label,
      data: graph.data,
      borderColor: graph.color,
      borderWidth: 2,
      pointRadius: 0,
      stepped: "after",
      tension: 0
    }]
  
    this.chart.options.scales.x.title.text = graph.label
  
    this.chart.resetZoom()
    this.chart.update()
  }

  handleKeydown(event) {
    if (["INPUT", "TEXTAREA", "SELECT"].includes(event.target.tagName)) return
    if (!this.chart) return

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.chart.pan({ x: 50 })
        break

      case "ArrowRight":
        event.preventDefault()
        this.chart.pan({ x: -50 })
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
