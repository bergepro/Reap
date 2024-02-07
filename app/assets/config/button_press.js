document.addEventListener("DOMContentLoaded", function () {
  const billableButton = document.getElementById("billableButton");
  const nonBillableButton = document.getElementById("nonBillableButton");

  // Add click event listeners to the buttons
  billableButton.addEventListener("click", function () {
    nonBillableButton.classList.remove("active-button");
    billableButton.classList.add("active-button");
  });

  nonBillableButton.addEventListener("click", function () {
    billableButton.classList.remove("active-button");
    nonBillableButton.classList.add("active-button");
  });
});
