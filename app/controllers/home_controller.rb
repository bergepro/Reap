class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @time_regs = current_user.time_regs.order('time_regs.date_worked DESC', 'time_regs.assigned_task_id')
  end
end
