import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-tasks"
export default class extends Controller {

  // updates the tasks in the time_reg form on a project change
  connect() {
    const projectSelect = document.querySelector('#timeproject-select');
    const taskSelect = document.querySelector('#timetask-select');

    projectSelect.addEventListener('change', (event) =>{
      const projectId = event.target.value;
      $.ajax({
        type: 'GET',
        url: `/time_regs/update_tasks_select?project_id=${projectId}`,
        success:(data)=>{

          // checks if the project id returned any tasks from the server
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
