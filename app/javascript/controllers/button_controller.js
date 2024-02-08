import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["billableButton", "nonBillableButton"];

  connect() {
    console.log("Controller connected");
  }

  toggleActive(event) {
    const clickedButton = event.currentTarget;

    // Remove "active-button" class from all buttons
    this.element
      .querySelectorAll(".Billable-Button, .Non-Billable-Button")
      .forEach((btn) => btn.classList.remove("active-button"));

    // Add "active-button" class only to the clicked button
    clickedButton.classList.add("active-button");
  }
}
