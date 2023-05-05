import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reports"
export default class extends Controller {

  connect() {
    const projectSelect = document.querySelector('#project-select');
    const taskCheckboxes = document.querySelector('#task-checkboxes');
    const memberCheckboxes = document.querySelector('#member-checkboxes');

    const timeframeSelect = document.querySelector('#timeframe-select');
    const customTimeframe = document.querySelector('#custom-timeframe');
    
    const clientSelect = document.querySelector('#client-select');
    
    clientSelect.addEventListener('change', (event) =>{
      const clientId = event.target.value;

      if(clientId < 1){
        projectSelect.innerHTML = "<option>No projects found</option>";
        taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
        memberCheckboxes.innerHTML = "<label>No members found.</label>";
        return;
      }

      $.ajax({
        type: 'GET',
        url: `/reports/update_projects_select?client_id=${clientId}`,
        success:(data)=>{
          projectSelect.innerHTML = data;

          const projectId = projectSelect.value;
          if(projectId < 1){
            projectSelect.innerHTML = "<option>No Projects found</option>"
            taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
            memberCheckboxes.innerHTML = "<label>No members found.</label>";
            return;
          }
          else{
          }

          updateCheckboxes(taskCheckboxes, projectId, "update_task_checkboxes")
          updateCheckboxes(memberCheckboxes, projectId, "update_member_checkboxes")
        },
        error:(data)=>{
          console.error(data);
        }
      })
    })

    timeframeSelect.addEventListener('change', (event) =>{
      const timeframeValue = event.target.value;
      if(timeframeValue == 'custom'){
        $.ajax({
          type: 'GET',
          url: `/reports/render_custom_timeframe`,
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

    projectSelect.addEventListener('change', (event) => {
      const projectId = event.target.value;
      console.log(projectId)
      if(projectId < 1){
        taskCheckboxes.innerHTML = "<label>No tasks found.</label>";
        memberCheckboxes.innerHTML = "<label>No members found.</label>";
        return;
      }
  
      updateCheckboxes(taskCheckboxes, projectId, "update_task_checkboxes")
      updateCheckboxes(memberCheckboxes, projectId, "update_member_checkboxes")

    }); 
    
    function updateCheckboxes(checkboxes, id, controllerMethod) {
      $.ajax({
        type: 'GET',
        url: `/reports/${controllerMethod}?project_id=${id}`,
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
