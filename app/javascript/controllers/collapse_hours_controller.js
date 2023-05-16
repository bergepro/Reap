import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapse-hours"
export default class extends Controller {
  // creates a eventlistener on every button on every task in the project page
  connect() {
    let collapsibles = document.getElementsByClassName('collapsible'); // each button
  
    // iterates over every task collapsible div
    for(let i = 0; i < collapsibles.length; i++){
      let button = collapsibles[i];
      let collapsibleId = "collapsible-" + button.dataset.taskId;
      let collapsible = document.getElementById(collapsibleId)
  
      // toggles a collapse div visibility with everyones hours
      button.addEventListener('click', () => {
          collapsible.classList.toggle('hidden');
      });
    }  
  }
}
