import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reports"
export default class extends Controller {

  connect() {
    const projectSelect = document.querySelector('#project-select');
    const taskCheckboxes = document.querySelector('#task-checkboxes');
    const memberCheckboxes = document.querySelector('#member-checkboxes');

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
