import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-reports"
export default class extends Controller {

  connect() {    
    // gets timeframe select field, and custom-timeframe div
    const timeframeSelect = document.querySelector('#timeframe-select');
    const customTimeframe = document.querySelector('#custom-timeframe');

    // gets project and client select fields
    const projectSelect = document.querySelector('#project-select');
    const clientSelect = document.querySelector('#client-select');

    // gets the member and task checkboxes
    const taskCheckboxes = document.querySelector('#task-checkboxes');
    const memberCheckboxes = document.querySelector('#member-checkboxes');

    // event-listener on the client select-field
    clientSelect.addEventListener('change', (event) =>{
      const clientId = event.target.value;
      const URL =  `/project_reports/update_projects_select?client_id=${clientId}` // AJAX URL

      // checks if the id is valid
      if(clientId < 1){
        projectSelect.innerHTML = "<option>No projects found</option>";
        taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
        memberCheckboxes.innerHTML = "<label>No members found.</label>";
        return;
      }

      // does an AJAX request to the server to get the projects 
      $.ajax({
        type: 'GET',
        url: URL,
        success:(data)=>{
          projectSelect.innerHTML = data;

          const projectId = projectSelect.value; // does it return any projects?

          // if it did not return any projects
          if(projectId < 1){
            projectSelect.innerHTML = "<option>No Projects found</option>";
            taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
            memberCheckboxes.innerHTML = "<label>No members found.</label>";
            return;
          }
          else{
            // else: update the checkboxes content
            updateCheckboxes(taskCheckboxes, 'task', projectId);
            updateCheckboxes(memberCheckboxes, 'member', projectId);            
          }
        },
        error:(data)=>{
          console.error(data);
        }
      })
    })

    // eventListener on the timeframe select-field 
    timeframeSelect.addEventListener('change', (event) =>{
      const URL = `/project_reports/render_custom_timeframe`; // URL to the server "route"
      const timeframeValue = event.target.value; 

      // checks if timeframe == "custom" to render the date-fields
      if(timeframeValue == 'custom'){
        $.ajax({
          type: 'GET',
          url: URL,
          success: (data) =>{
            customTimeframe.innerHTML = data;
          },
          error: (data) =>{
              console.error(data);
          }
        });
      }
      else{
        customTimeframe.innerHTML = null;
      }
    });

    // eventListener on the project select-field
    projectSelect.addEventListener('change', (event) => {
      const projectId = event.target.value;

      // checks if project is valid
      if(projectId < 1){
        taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
        memberCheckboxes.innerHTML = "<label>No members found.</label>";
      }
      else{
        // updates the checkboxes with the project's tasks and members
        updateCheckboxes(taskCheckboxes, 'task', projectId)
        updateCheckboxes(memberCheckboxes, 'member', projectId)
      }

    }); 
    
    function updateCheckboxes(checkboxes, cbType, id) {
      // URL to the server "route"
      const URL = `/project_reports/update_${cbType}_checkboxes?project_id=${id}`

      // does an AJAX request to the server to get the objects for checkboxes 
      $.ajax({
        type: 'GET',
        url: URL,
        success: (data) => {
          checkboxes.innerHTML = data;
        },
        error: (data) => {
          console.error(data);
        }
      });
    }

  }
}
