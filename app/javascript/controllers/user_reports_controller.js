import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-reports"
export default class extends Controller {
  connect() {
    this.addListeners();
  }

  // creates event listeners on the form fields
  addListeners(){
    const timeframeSelection = document.querySelector('#timeframe-selection');
    const userSelection = document.querySelector('#user-selection');
    const checkAlltasks = document.querySelector('#check-all-tasks');
  
    if(timeframeSelection)
      this.addCustomTimeframeListener(timeframeSelection);
    
    if(userSelection)
      this.addUserListener(userSelection);

    if(checkAlltasks)
      this.addCheckAllTasksListener(checkAlltasks);
  }

  // event listener on the check all 
  addCheckAllTasksListener(checkAlltasks){      
    checkAlltasks.addEventListener('click', (event) =>{
      // gets every checkboxes that is rendered
      const taskCheckboxes = document.querySelectorAll('[id^="user_report_task_id"]');
      
      // checks every box with the value of the check-all box
      taskCheckboxes.forEach( inspectBox  => {
        inspectBox.checked = event.target.checked;
      })
    });
  }

  // eventlistener on the timeframe selection to toggle visibility if custom
  addCustomTimeframeListener(timeframeSelection){
    const customTimeframeDiv = document.querySelector('#custom-timeframe-container');

    timeframeSelection.addEventListener('change', (event)=>{
      if(timeframeSelection.value == "custom")
        customTimeframeDiv.classList.remove('hidden');
      else
        customTimeframeDiv.classList.add('hidden');
    });
  }

  // eventlistener on the user selection
  addUserListener(userSelection){
    const projectsDiv = document.querySelector('#projects-checkboxes');
    const tasksDiv = document.querySelector('#tasks-checkboxes')

    userSelection.addEventListener('change', (event) =>{
      const userId = userSelection.value

      // if valid user get the projects from server
      if (userId > 0){
        $.ajax({
          type: 'GET',
          url: `/user_reports/update_projects_checkboxes`,
          data: {user_id: userId},
          success:(data)=>{
            projectsDiv.innerHTML = data;
            tasksDiv.innerHTML = null;
          },
          error:(data)=>{
            console.error(data);
          }
        })       
      }
      else{
        projectsDiv.innerHTML = null;
        tasksDiv.innerHTML = null;
      }
    });
  }
}
