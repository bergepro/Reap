import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-reports-boxes"
export default class extends Controller {

  connect() {
    this.addTasksCheckListener();
  }

  // event listener on the project checkboxes
  addTasksCheckListener(){
    const projectCheckboxes = document.querySelectorAll('[id^="user_report_project_id"]');
    const tasksDiv = document.querySelector('#tasks-checkboxes');

    projectCheckboxes.forEach( checkbox => {
      checkbox.addEventListener('click', event =>{
      let checkedBoxes = [];

      // gets every checkbox that is checked 
      projectCheckboxes.forEach( inspectBox  => {
        if(inspectBox.checked){
          checkedBoxes.push(inspectBox.value);
        }  
      })

      // gets tasks in projects from checked projects
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

  // eventlistener on the check-all projects checkbox
  addCheckAllProjectsListener(){
    const projectCheckboxes = document.querySelectorAll('[id^="user_report_project_id"]');
    const tasksDiv = document.querySelector('#tasks-checkboxes');

    // checks all project checkboxes with check-all checkbox value
    projectCheckboxes.forEach( inspectBox  => {
      inspectBox.checked = event.target.checked;
    })

    // gets every checked box
    let checkedBoxes = [];
    projectCheckboxes.forEach( inspectBox  => {
      if(inspectBox.checked){
        checkedBoxes.push(inspectBox.value);
      }  
    })

    // fills the tasks checkboxes with every task from the checked projects
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
