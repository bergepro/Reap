class TimeRegsController < ApplicationController
  before_action :authenticate_user!

  require 'activerecord-import/base'
  require 'csv'
  include TimeRegsHelper

  def index
    @chosen_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @time_regs = current_user.time_regs.where('date(date_worked) = ?', @chosen_date).includes(:project, :assigned_task).order(created_at: :desc)
    @total_minutes_day = @time_regs.sum(:minutes)
    @minutes_by_day = minutes_by_day_of_week(@chosen_date, current_user)
    @projects = current_user.projects
    @time_reg = TimeReg.new(date_worked: Date.today)

    # calculate the start and end date of the week of @chosen_date
    start_date = @chosen_date.beginning_of_week
    end_date = @chosen_date.end_of_week

    @time_regs_week = current_user.time_regs.where('date(date_worked) BETWEEN ? AND ?', start_date, end_date)
    @total_minutes_week = @time_regs_week.sum(:minutes)
  end

  def new
    @projects = current_user.projects
    @time_reg = TimeReg.new
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

    if @time_reg.save
      flash[:notice] = 'Time entry has been created'
      redirect_to time_regs_path
    else
      @show_new = true
      @chosen_date = params[:date] ? Date.parse(params[:date]) : Date.today
      @time_regs = current_user.time_regs.where('date(date_worked) = ?', @chosen_date).includes(:project, :assigned_task).order(created_at: :desc)

      @projects = current_user.projects

      @total_minutes_day = @time_regs.sum(:minutes)
      @minutes_by_day = minutes_by_day_of_week(@chosen_date, current_user)

      # calculate the start and end date of the week of @chosen_date
      start_date = @chosen_date.beginning_of_week
      end_date = @chosen_date.end_of_week

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

    if @time_reg.update(time_reg_params.except(:project_id))
      redirect_to time_regs_path
      flash[:notice] = "Time entry has been updated"
    else
      @projects = current_user.projects
      @assigned_tasks = Task.joins(:assigned_tasks)
      .where(assigned_tasks: { project_id: @time_reg.project.id })
      .pluck(:name, 'assigned_tasks.id')

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_reg = TimeReg.find(params[:id])

    if @time_reg.destroy
      redirect_to time_regs_path
      flash[:notice] = "Time entry has been deleted"
    else
      @projects = current_user.projects
      @assigned_tasks = Task.joins(:assigned_tasks)
        .where(assigned_tasks: { project_id: @time_reg.project.id })
        .pluck(:name, 'assigned_tasks.id')

      flash[:alert] = "cannot delete time entry"
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_active
    @time_reg = TimeReg.find(params[:time_reg_id])
    @project = @time_reg.project

    # if time_reg is active, it toggles off and updates the minutes += the minutes passed since the timer started
    if @time_reg.active
      new_timestamp = Time.now

      old_time = @time_reg.updated.to_i
      new_time = new_timestamp.to_i

      worked_minutes = (new_time - old_time) / 60

      @time_reg.minutes += worked_minutes
      @time_reg.active = false
    # if not active, it starts the timer
    else
      @time_reg.updated = Time.now
      @time_reg.active = true
    end

    # tries to save the changes
    if @time_reg.save
      redirect_to time_regs_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  # exports the time_regs in a project to a .CSV
  def export
    project = Project.find(params[:project_id])
    client = project.client
    time_regs = project.time_regs.includes(
      :task,
      :user,
      membership: [:user],
      assigned_task: [:project, :task],
      project: :client,
    )
    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      time_regs.each do |time_reg|
        csv << [time_reg.date_worked, client.name, project.name, time_reg.assigned_task.task.name, 
          time_reg.notes, time_reg.minutes, time_reg.user.first_name, time_reg.user.last_name, time_reg.user.email]
      end
    end
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_#{project.name}.csv"
  end

  # changes the selection tasks to show tasks from a specific project
  def update_tasks_select
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: params[:project_id] }).pluck(:name, 'assigned_tasks.id')
    render partial: '/time_regs/select', locals: {tasks: @tasks}
  end

  private
  def time_reg_params
    params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :date_worked, :project_id)
  end

end
