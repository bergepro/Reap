import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-minutes"
export default class extends Controller {
  static targets = ['minutes', 'updated', 'output'] 

  
  connect() {
    const divTarget = this.outputTarget; 
    const timeRegminutes = this.minutesTarget.dataset.minutes;
    const targetDateTime = new Date(this.updatedTarget.dataset.updated);

    if (divTarget) {
      this.updateMinutes(divTarget, targetDateTime, timeRegminutes);
      this.intervalId = setInterval(() => this.updateMinutes(divTarget, targetDateTime, timeRegminutes), 2000); // 2 second margin
    } else {
      console.error('missing target');
    }
  }

  updateMinutes(divTarget, targetDateTime, timeRegminutes){
    const currentTime = new Date();
    divTarget.innerHTML = this.convertTime(targetDateTime, currentTime, timeRegminutes)
  }

  disconnect() {
    const divTarget = this.outputTarget;

    if (divTarget) 
      clearInterval(this.intervalId);
  }

  convertTime(targetDateTime, currentTime, timeRegminutes){
    const timeDifference = currentTime - targetDateTime;
    const minutesDifference = Math.floor((timeDifference / 1000 / 60));
    const minutesTotal = minutesDifference+Number(timeRegminutes);

    const hours = Math.floor(minutesTotal/60);
    const minutes = Math.floor(minutesTotal%60);

    return `${hours}:${minutes}`;
  }
}
