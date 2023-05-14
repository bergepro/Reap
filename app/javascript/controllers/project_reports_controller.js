import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-reports"
export default class extends Controller {

  connect() {
    this.addEventListeners();
  }

  addEventListeners(){
    const timeframeSelection = document.querySelector('#timeframe-selection');
    const clientSelection = document.querySelector('#client-selection');
    const projectSelection = document.querySelector('#project-selection');

    if(timeframeSelection)
      this.addCustomTimeframeListener(timeframeSelection);

    if(clientSelection)
      this.addClientSelectionListener(clientSelection);
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

  addClientSelectionListener(clientSelection){
    const projectSelection = document.querySelector('#project-selection');

    clientSelection.addEventListener('change', event=>{
      const clientId = clientSelection.value;

      if (clientId > 0){
        $.ajax({
          type: 'GET',
          url: `/project_reports/update_projects_selection`,
          data: {client_id: clientId},
          success:(data)=>{
            projectSelection.innerHTML = data;
          },
          error:(data)=>{
            console.error(data);
          }
        })       
      }
    });
  }
}
