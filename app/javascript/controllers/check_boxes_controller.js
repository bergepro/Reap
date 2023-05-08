import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="check-boxes"
export default class extends Controller {
  connect() {
    const checkTaskElement = document.querySelector('#check_all_tasks');
    const checkMemberElement = document.querySelector('#check_all_members');

    if (checkTaskElement != null)
      checkAll(checkTaskElement, "task") 
    if (checkMemberElement != null)
      checkAll(checkMemberElement, "member") 

    function checkAll(checkElement, checkName){
      checkElement.addEventListener('change', (event) => {
        let checkboxes = document.getElementsByName((checkName+'_ids[]'));
        for (let checkbox of checkboxes) {
          checkbox.checked = event.target.checked;
        }
      });     
    }
  }
}
