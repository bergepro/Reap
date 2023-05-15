class TimeRegsController < ApplicationController
  before_action :authenticate_user!
  #before_action :ensure_membership, except: [:new, :create]
  #skip_before_action :ensure_membership, only: :toggle_active

  require 'activerecord-import/base'
  require 'csv'

  def index
    @time_regs = current_user.time_regs.order('time_regs.date_worked DESC', 'time_regs.assigned_task_id', 'time_regs.created_at DESC')
  end

  def new
    @projects = current_user.projects
    @time_reg = TimeReg.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end


  def create
    @project = Project.find(time_reg_params[:project_id])
    @time_reg = @project.time_regs.build(time_reg_params.except(:project_id))
   
    membership = @project.memberships.find_by(user_id: current_user.id, project_id: @project.id)

    @time_reg.active = false
    @time_reg.updated = Time.now
    @time_reg.membership_id = membership.id

    @projects = current_user.projects
    if @time_reg.save
      flash[:notice] = 'Time entry has been created'
      redirect_to time_regs_path
    else
      flash[:alert] = 'Cannot create time entry'
      render :new, status: :unprocessable_entity 
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
    puts "-----------"
    puts params.inspect

    @time_reg = TimeReg.find(params[:id])

    if @time_reg.update(time_reg_params.except(:project_id))
      redirect_to time_regs_path
      flash[:notice] = "Time entry has been updated"
    else
      flash[:alert] = "cannot update time entry" 
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

  def export
    @project = Project.find(params[:project_id])
    @client = @project.client
    @time_regs = @project.time_regs

    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      @time_regs.each do |time_reg|
        membership = Membership.find(time_reg.membership_id)

        date = time_reg.date_worked
        client = @client.name
        project = @project.name
        task = time_reg.assigned_task.task.name
        notes = time_reg.notes
        minutes = time_reg.minutes
        first_name = time_reg.user.first_name
        last_name = time_reg.user.last_name
        email = time_reg.user.email

        csv << [date, client, project, task, notes, minutes, first_name, last_name, email]
      end
    end

    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_#{@project.name}.csv"
  end

  def update_tasks_select
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: params[:project_id] }).pluck(:name, 'assigned_tasks.id')
    render partial: '/time_regs/select', locals: {tasks: @tasks}
  end

  private
  def time_reg_params
    params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :date_worked, :project_id)
  end

  def skip_ensure_membership_for_toggle_active
    skip_before_action :ensure_membership
  end
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
