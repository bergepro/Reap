import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-tasks"
export default class extends Controller {
  connect() {
    const projectSelect = document.querySelector('#timeproject-select');
    const taskSelect = document.querySelector('#timetask-select');


    // gets every task from a specific project from the project and updates the task selection field
    projectSelect.addEventListener('change', (event) =>{
      const projectId = event.target.value;
      $.ajax({
        type: 'GET',
        url: `/time_regs/update_tasks_select?project_id=${projectId}`,
        success:(data)=>{
          taskSelect.innerHTML = data;

          const taskId = projectSelect.value
          if(taskId < 1){
            taskSelect.innerHTML = "<option>No Tasks found</option>";
          }
        },
        error:(data)=>{
          console.error(data);
        }
      })
    });
  }
}
