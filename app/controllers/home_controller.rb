class HomeController < ApplicationController
  before_action :authenticate_user!
  include HomeHelper
  def index
    @chosen_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @time_regs = current_user.time_regs.where('date(date_worked) = ?', @chosen_date)
    @total_minutes_day = @time_regs.sum(:minutes)
    @minutes_by_day = minutes_by_day_of_week(@chosen_date, current_user)

    # calculate the start and end date of the week of @chosen_date
    start_date = @chosen_date.beginning_of_week
    end_date = @chosen_date.end_of_week

    @time_regs_week = current_user.time_regs.where('date(date_worked) BETWEEN ? AND ?', start_date, end_date)
    @total_minutes_week = @time_regs_week.sum(:minutes)
  end
end

