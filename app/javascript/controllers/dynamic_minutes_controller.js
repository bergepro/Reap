import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-minutes"
export default class extends Controller {
  connect() {
    const timeView = document.querySelector('#time-view')

    console.log("dynaimic")
    this.userId = this.data.get("user-id");
    this.startUpdatingMinutes(this.userId, timeView);
  }

  startUpdatingMinutes(userId, timeView) {
    this.intervalId = setInterval(() => {
      this.updateMinutes(userId, timeView);
    }, 60500);
  }

  updateMinutes(userId, timeView){
    console.log(userId);
    $.ajax({
      type: 'GET',
      url: `/time_regs/update_minutes_view?user_id=${userId}`,
      success: (data) =>{
        timeView.innerHTML = data;
      },
      error: (data) =>{
          console.error(data);
      }
    });
  }
}
