import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-edit"
export default class extends Controller {
  static targets = ['toggleDiv'];
  connect() {
  }

  editReport(event) {
    this.toggleDivTarget.classList.toggle('hidden');
  }
}
