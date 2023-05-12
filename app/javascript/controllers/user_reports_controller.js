import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-reports"
export default class extends Controller {
  static targets = ['projectsDiv'];

  connect() {
    const tasks_url = `/user_reports/update_tasks` 
    const checkboxes = document.querySelectorAll("[id^='project_ids']");
    const taskDiv = document.querySelector("#task-div")
    this.sendCheckboxesToServer(checkboxes, tasks_url, taskDiv)


    const checkAllProjects = document.querySelector("#check_all_projects");

    if(checkAllProjects){
      this.checkAll(checkAllProjects,checkboxes, tasks_url, taskDiv);
    }
  }

  checkAll(checkAllProjects, checkboxes, tasks_url, taskDiv){
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

  sendCheckboxesToServer(checkboxes, tasks_url, taskDiv){
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', event =>{
        let selectedCheckboxes = [];
        checkboxes.forEach(check =>{
          if(check.checked){
            selectedCheckboxes.push(check.value);
          }
        })

        const selectedCheckboxesJSON = JSON.stringify(selectedCheckboxes);
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
        console.log("hei")
      })
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
