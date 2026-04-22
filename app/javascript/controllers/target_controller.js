import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("target controller connected");
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    const name  = event.currentTarget.dataset.name
  
    window.location.href = `/records?target=${value}&target_name=${encodeURIComponent(name)}`
  }
}
