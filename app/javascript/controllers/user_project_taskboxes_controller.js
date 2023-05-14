import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-project-taskboxes"
export default class extends Controller {
  connect() {
    const checkAllTasks = document.querySelector("#check_all_tasks");

    if (checkAllTasks){
      this.checkAll(checkAllTasks, 'task');
    }

  }

  checkAll(checkAll, string){
    checkAll.addEventListener('change', (event) =>{
      let checkboxIdString = "[id^='"+string+"_ids']"
      let checkboxes = document.querySelectorAll(checkboxIdString);

      // iterates over every checkbox and toggles it with checkAll box value
      for (let checkbox of checkboxes) {
        checkbox.checked = event.target.checked;
      }
    })
  }
}
