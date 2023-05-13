import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-reports-boxes"
export default class extends Controller {

  connect() {
    this.addTasksCheckListener();
  }

  addTasksCheckListener(){
    const projectCheckboxes = document.querySelectorAll('[id^="user_report_project_id"]');
    const tasksDiv = document.querySelector('#tasks-checkboxes');

    projectCheckboxes.forEach( checkbox => {

      checkbox.addEventListener('click', event =>{
      let checkedBoxes = [];
        projectCheckboxes.forEach( inspectBox  => {
          if(inspectBox.checked){
            checkedBoxes.push(inspectBox.value);
          }  
        })

        $.ajax({
          type: 'GET',
          url: `/user_reports/update_tasks_checkboxes`,
          data: {project_ids: checkedBoxes},
          success:(data)=>{
            tasksDiv.innerHTML = data;
          },
          error:(data)=>{
            console.error(data);
          }
        })
      })
    });
  }

  addCheckAllProjectsListener(){
    const projectCheckboxes = document.querySelectorAll('[id^="user_report_project_id"]');
    const tasksDiv = document.querySelector('#tasks-checkboxes');

    projectCheckboxes.forEach( inspectBox  => {
      inspectBox.checked = event.target.checked;
    })
    
    let checkedBoxes = [];
    projectCheckboxes.forEach( inspectBox  => {
      if(inspectBox.checked){
        checkedBoxes.push(inspectBox.value);
      }  
    })

    $.ajax({
      type: 'GET',
      url: `/user_reports/update_tasks_checkboxes`,
      data: {project_ids: checkedBoxes},
      success:(data)=>{
        tasksDiv.innerHTML = data;
      },
      error:(data)=>{
        console.error(data);
      }
    })
  }
  
}
