import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-reports"
export default class extends Controller {
  
  static targets = ['projectsDiv'];

  connect() {    
    console.log("connect")

    // gets timeframe select field, and custom-timeframe div
    const timeframeSelect = document.querySelector('#timeframe-select');
    const customTimeframe = document.querySelector('#custom-timeframe');

    const tasks_url = `/user_reports/update_tasks` 
    const checkboxes = document.querySelectorAll("[id^='project_ids']");
    const taskDiv = document.querySelector("#task-div")
    const checkAllProjects = document.querySelector("#check_all_projects");
   
        
    let selectedTasks = null;
    if (this.element.dataset.selectedTasks != null) {
      selectedTasks = JSON.parse(this.element.dataset.selectedTasks);
    }

    this.CreateCheckboxListeners(checkboxes, tasks_url, taskDiv)
    this.checkboxesToServer(checkboxes, tasks_url, taskDiv, selectedTasks)

    if(checkAllProjects){
      this.checkAll(checkAllProjects,checkboxes, tasks_url, taskDiv);
    }

    // eventListener on the timeframe select-field 
    timeframeSelect.addEventListener('change', (event) =>{
      const URL = `/user_reports/render_custom_timeframe`; // URL to the server "route"
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
  }


  checkAll(checkAllProjects, checkboxes, tasks_url, taskDiv){
    console.log("check all")
    checkAllProjects.addEventListener('change', (event) =>{
      let CheckedList = [];
      for (let checkbox of checkboxes) {
        checkbox.checked = event.target.checked;
        if (event.target.checked)
          CheckedList.push(checkbox.value);
      }
      const selectedCheckboxesJSON = JSON.stringify(CheckedList);

      $.ajax({
        type: 'GET',
        url: tasks_url,
        data: {project_ids_json: selectedCheckboxesJSON},
        success: (data) =>{
          taskDiv.innerHTML = data;
        },
        error: (data) =>{
            console.error(data);
        }
      });
    })
  }

  CreateCheckboxListeners(checkboxes, tasks_url, taskDiv, selectedTasks){
    console.log("create cb listeners")

    if(checkboxes.length > 0){
      checkboxes.forEach(checkbox => {

        checkbox.addEventListener('change', event =>{
          this.checkboxesToServer(checkboxes, tasks_url, taskDiv, selectedTasks)
        })
      });      
    }
  }

  checkboxesToServer(checkboxes, tasks_url, taskDiv, selectedTasks){
    console.log("checkboxes to server")
    let selectedCheckboxes = [];
    checkboxes.forEach(check =>{
      if(check.checked){
        selectedCheckboxes.push(check.value);
      }
    })
    const selectedCheckboxesJSON = JSON.stringify(selectedCheckboxes);
    const selectedTasksJSON = JSON.stringify(selectedTasks)
    $.ajax({
      type: 'GET',
      url: tasks_url,
      data: {project_ids_json: selectedCheckboxesJSON, selected_task_ids_json: selectedTasksJSON},
      success: (data) =>{
        taskDiv.innerHTML = data;
      },
      error: (data) =>{
          console.error(data);
      }
    });
  }

  handleChange(event){
    const userId = event.target.value;
    const taskDiv = document.querySelector("#task-div")
    if(userId < 1){
      this.projectsDivTarget.innerHTML =  "no projects found"; 
      taskDiv.innerHTML = "Please select atleast one project"
      return;     
    }
    else{
      const projects_url = `/user_reports/update_projects?user_id=${userId}`

      // checks if timeframe == "custom" to render the date-fields
      $.ajax({
        type: 'GET',
        url: projects_url,
        success: (data) =>{
          this.projectsDivTarget.innerHTML = data;
          taskDiv.innerHTML = "Please select atleast one project"
          
        },
        error: (data) =>{
            console.error(data);
        }
      });
    }
  }

  

}
