import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"
import zoomPlugin from "chartjs-plugin-zoom"

Chart.register(...registerables, zoomPlugin)

export default class extends Controller {
  static targets = ["canvas", "select", "userSelect", "userListContainer", "userHiddenInput"]
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
            min: 0,
            title: {
              display: true,
              text: "値"
            }
          },
          y: {
            min: 0,
            max: 1,
            ticks: {
              callback: (value) => `${Math.round(value * 100)}%`
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
              x: { min: 0, max: "original" }
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

  addUser(event) {
    event.preventDefault()
    if (!this.hasUserSelectTarget) return

    const selectEl = this.userSelectTarget
    const userId = selectEl.value
    if (!userId) return

    const badgeItem = this.element.querySelector(`.user-badge-item[data-user-id="${userId}"]`)
    if (badgeItem) {
      badgeItem.classList.remove("d-none")
      const hiddenInput = badgeItem.querySelector('input[type="hidden"]')
      if (hiddenInput) {
        hiddenInput.disabled = false
      }
    }

    selectEl.value = ""
  }

  removeUser(event) {
    event.preventDefault()
    const badgeItem = event.currentTarget.closest(".user-badge-item")
    if (!badgeItem) return

    badgeItem.classList.add("d-none")
    const hiddenInput = badgeItem.querySelector('input[type="hidden"]')
    if (hiddenInput) {
      hiddenInput.disabled = true
    }
  }

  changeGraph() {
    if (!this.chart) return

    const selectedMetric = this.selectTargets.find(radio => radio.checked)
    if (!selectedMetric) return

    const graph = this.graphDataValue[Number(selectedMetric.value)]
    if (!graph) return

    // 旧データ構造（graph.data）が渡ってきた場合のフォールバックにも対応
    if (!graph.datasets && graph.data) {
      this.chart.data.datasets = [{
        label: graph.label,
        data: graph.data,
        borderColor: graph.color,
        borderWidth: 2,
        pointRadius: 0,
        stepped: "after",
        tension: 0
      }]
    } else if (Array.isArray(graph.datasets)) {
      const activeUserIds = this.userHiddenInputTargets
        .filter(input => !input.disabled)
        .map(input => String(input.value))

      const targetDatasets = activeUserIds.length === 0
        ? []
        : graph.datasets.filter((ds) => {
            if (ds.userId === undefined) return true
            return activeUserIds.includes(String(ds.userId))
          })

      this.chart.data.datasets = targetDatasets.map(ds => ({
        label: ds.label,
        data: ds.data,
        borderColor: ds.color,
        backgroundColor: ds.color,
        borderWidth: 2,
        pointRadius: 0,
        stepped: "after",
        tension: 0
      }))
    }

    this.chart.options.scales.x.title.text = graph.label
    this.chart.resetZoom()
    this.chart.update()
  }

  handleKeydown(event) {
    if (["TEXTAREA", "SELECT"].includes(event.target.tagName)) return
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
