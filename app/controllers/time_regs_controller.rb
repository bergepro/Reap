class TimeRegsController < ApplicationController
  before_action :authenticate_user!
  #before_action :ensure_membership, except: [:new, :create]
  #skip_before_action :ensure_membership, only: :toggle_active

  require 'activerecord-import/base'
  require 'csv'

  include TimeRegsHelper
  def index
    @chosen_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @time_regs = current_user.time_regs.where('date(date_worked) = ?', @chosen_date)
    @total_minutes_day = @time_regs.sum(:minutes)
    @minutes_by_day = minutes_by_day_of_week(@chosen_date, current_user)
    @projects = current_user.projects
    @time_reg = TimeReg.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end

    # calculate the start and end date of the week of @chosen_date
    start_date = @chosen_date.beginning_of_week
    end_date = @chosen_date.end_of_week

    @time_regs_week = current_user.time_regs.where('date(date_worked) BETWEEN ? AND ?', start_date, end_date)
    @total_minutes_week = @time_regs_week.sum(:minutes)
  end
  
=begin
  def index
    @time_regs = current_user.time_regs.order('time_regs.date_worked DESC', 'time_regs.assigned_task_id', 'time_regs.created_at DESC')
  end
=end
  def new
    @projects = current_user.projects
    @time_reg = TimeReg.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end


  def create
    # gives the time_reg all the attributes
    if Project.exists?(time_reg_params[:project_id])
      @project = Project.find(time_reg_params[:project_id])
      @time_reg = @project.time_regs.build(time_reg_params.except(:project_id))     
      membership = @project.memberships.find_by(user_id: current_user.id, project_id: @project.id) 
      @time_reg.membership_id = membership.id     
    else
      @time_reg = TimeReg.new(time_reg_params.except(:project_id))
    end
    
    @time_reg.active = @time_reg.minutes == 0 ? true : false # start as active?
    @time_reg.updated = Time.now

    # tries to save the time_reg
    if @time_reg.save
      flash[:notice] = 'Time entry has been created'
      redirect_to time_regs_path
    else
      
      @chosen_date = params[:date] ? Date.parse(params[:date]) : Date.today
      @projects = current_user.projects
      @time_regs = current_user.time_regs.where('date(date_worked) = ?', @chosen_date)
      @total_minutes_day = @time_regs.sum(:minutes)
      @minutes_by_day = minutes_by_day_of_week(@chosen_date, current_user)

      # calculate the start and end date of the week of @chosen_date
      start_date = @chosen_date.beginning_of_week
      end_date = @chosen_date.end_of_week

      @show_new = true

      @time_regs_week = current_user.time_regs.where('date(date_worked) BETWEEN ? AND ?', start_date, end_date)
      @total_minutes_week = @time_regs_week.sum(:minutes)

      render :index, status: :unprocessable_entity 
    end
  end


  def edit
    @time_reg = TimeReg.find(params[:id])
    @projects = current_user.projects
    @assigned_tasks = Task.joins(:assigned_tasks)
      .where(assigned_tasks: { project_id: @time_reg.project.id })
      .pluck(:name, 'assigned_tasks.id')
  end 

  def update
    @time_reg = TimeReg.find(params[:id])

    # changes the membership id on project change
    membership = Membership.find_by(user_id: current_user.id, project_id: time_reg_params[:project_id])
    @time_reg.membership_id = membership.id

    # tries to update the time_Reg with new values
    if @time_reg.update(time_reg_params.except(:project_id))
      redirect_to time_regs_path
      flash[:notice] = "Time entry has been updated"
    else
      # re-renders form with errors
      @projects = current_user.projects
      @assigned_tasks = Task.joins(:assigned_tasks)
        .where(assigned_tasks: { project_id: @time_reg.project.id })
        .pluck(:name, 'assigned_tasks.id')   
      flash[:alert] = "cannot update time entry" 
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_reg = TimeReg.find(params[:id])

    # tries to delete the time_reg
    if @time_reg.destroy
      redirect_to time_regs_path
      flash[:notice] = "Time entry has been deleted"
    else
       # re-renders form with errors
      @projects = current_user.projects
      @assigned_tasks = Task.joins(:assigned_tasks)
        .where(assigned_tasks: { project_id: @time_reg.project.id })
        .pluck(:name, 'assigned_tasks.id')

      flash[:alert] = "cannot delete time entry"
      render :edit, status: :unprocessable_entity
    end
  end

  # every time a user toggles the start/stop button
  # if active: it takes the Time.now - last time it was updated
  # else not active: it sets the last updated as Time.new av changes status to active
  def toggle_active
    @time_reg = TimeReg.find(params[:time_reg_id])
    @project = @time_reg.project

    if @time_reg.active
      new_timestamp = Time.now

      old_time = @time_reg.updated.to_i
      new_time = new_timestamp.to_i

      worked_minutes = (new_time - old_time) / 60

      @time_reg.minutes += worked_minutes
      @time_reg.active = false
    else
      @time_reg.updated = Time.now
      @time_reg.active = true
    end

    if @time_reg.save
      redirect_to time_regs_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  # exports every time_reg in a project as a .CSV
  def export
    project = Project.find(params[:project_id])
    client = project.client
    time_regs = project.time_regs.includes(:user, :task)

    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      time_regs.each do |time_reg|
        csv << [time_reg.date_worked, project.client.name, project.name, time_reg.task.name, time_reg.notes, 
                    time_reg.minutes, time_reg.user.first_name, time_reg.user.first_name, time_reg.user.email]
      end
    end
    # downloads the .CSV
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_#{project.name}.csv"
  end

  # updates the tasks dynamically in the form on project change
  def update_tasks_select
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: params[:project_id] }).pluck(:name, 'assigned_tasks.id')
    render partial: '/time_regs/select', locals: {tasks: @tasks}
  end

  private

  # permits only valid attributes
  def time_reg_params
    params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :date_worked, :project_id)
  end

=begin
  def skip_ensure_membership_for_toggle_active
    skip_before_action :ensure_membership
  end
=end

=begin
  def ensure_membership
    if params[:id]
      project = TimeReg.find(params[:id]).assigned_task.project
    elsif params[:project_id]
      project = Project.find(params[:project_id])
    end

    if !project&.memberships&.exists?(user_id: current_user)
      flash[:alert] = "Access denied"
      redirect_to root_path
    end
  end
=end
end
