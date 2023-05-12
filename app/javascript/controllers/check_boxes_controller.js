import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="check-boxes"
export default class extends Controller {
  connect() {

    // gets the check-all boxes
    const checkTaskElement = document.querySelector('#check_all_tasks');
    const checkMemberElement = document.querySelector('#check_all_members');
  

    // if exixts call checkAll function with element
    if (checkTaskElement != null)
      checkAll(checkTaskElement, "task");
    if (checkMemberElement != null)
      checkAll(checkMemberElement, "member");


    //  that takes the element of the checkbox and the name 
    function checkAll(checkElement, checkName){
      // adds eventlistener to the checkbox
      checkElement.addEventListener('change', (event) => {
        let checkboxes = document.getElementsByName((checkName+'_ids[]')); // finds every checkbox from the name  

        // iterates over every checkbox and toggles it with checkAll box value
        for (let checkbox of checkboxes) {
          checkbox.checked = event.target.checked;
        }
      });     
    }
  }
}
