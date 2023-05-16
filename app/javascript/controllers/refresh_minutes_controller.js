import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="refresh-minutes"
export default class extends Controller {
  static targets = ['minutes', 'updated', 'output'];

  connect() {
    // gets every minutes and updated value from time_reg. get output target
    const outputTarget = this.outputTarget; 
    const timeRegminutes = this.minutesTarget.dataset.minutes;
    const timeRegDate = this.updatedTarget.dataset.updated;

    // checks if it found the output target
    if (outputTarget) {
      this.updateMinutes(outputTarget, timeRegDate, timeRegminutes); // updates on time

      // updates the minutes every minutes
      this.intervalId = setInterval(() => this.updateMinutes(outputTarget, timeRegDate, timeRegminutes), 62000); // 2 second margin
    } 
    else 
      console.error('missing target');
  }

  // function for updating the minutes
  updateMinutes(outputTarget, timeRegDate, timeRegminutes){
    outputTarget.innerHTML = this.convertTime(timeRegDate, timeRegminutes) // changes the targets html
  }

  // stops the interval
  disconnect() {
    const outputTarget = this.outputTarget;
    if (outputTarget){
        clearInterval(this.intervalId);

    }
  }

  convertTime(timeRegDate, timeRegminutes){
    // gets the dates
    const currentTime = new Date();
    const lastUpdatedTime = new Date(timeRegDate)

    // converts to total minutes worked
    const timeDifference = currentTime - lastUpdatedTime;
    const minutesDifference = Math.floor((timeDifference / 1000 / 60));
    const minutesTotal = minutesDifference+Number(timeRegminutes);

    // converts minutes to "0:00" format
    const hours = Math.floor(minutesTotal/60);
    const minutes = Math.floor(minutesTotal%60);
    if (minutes > 9)
      return `${hours}:${minutes}`;
    else
    return `${hours}:0${minutes}`;
  }

}
