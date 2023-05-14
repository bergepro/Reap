import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-reports"
export default class extends Controller {

  connect() {
    this.addEventListeners();
  }

  addEventListeners(){
    const timeframeSelection = document.querySelector('#timeframe-selection');

    if(timeframeSelection)
      this.addCustomTimeframeListener(timeframeSelection);
  }

  addCustomTimeframeListener(timeframeSelection){
    const customTimeframeDiv = document.querySelector('#custom-timeframe-container');

    timeframeSelection.addEventListener('change', (event)=>{
      if(timeframeSelection.value == "custom")
        customTimeframeDiv.classList.remove('hidden');
      else
        customTimeframeDiv.classList.add('hidden');
    });
  }
}
