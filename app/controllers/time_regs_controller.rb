class TimeRegsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_membership

  require 'activerecord-import/base'
  require 'csv'

  def new 
    @project = Project.find(params[:project_id]) if params[:project_id]
    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
      .joins(:assigned_tasks).where("project_id = #{@project.id}")
    @membership = @project.memberships.find_by(user_id: current_user.id)
    @time_reg = @project.time_regs.new
  end

  def create
    @project = Project.find(params[:project_id]) if params[:project_id]
    @time_reg = @project.time_regs.build(time_reg_params)
    @membership = @project.memberships.find_by(user_id: current_user.id)

    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
      .joins(:assigned_tasks).where("project_id = #{@project.id}")

    @time_reg.active = false
    @time_reg.updated = Time.now
    if @time_reg.save
      flash[:notice] = "Time entry has been created"
      redirect_to project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @time_reg = TimeReg.find(params[:id])
    @project = @time_reg.assigned_task.project
    @assigned_tasks = Task.select('DISTINCT name, assigned_tasks.id, project_id, task_id')
      .joins(:assigned_tasks).where("project_id = #{@project.id}")
    @membership = @project.memberships.find_by(user_id: current_user.id)
  end

  def update
    @time_reg = TimeReg.find(params[:id])
    @project = @time_reg.assigned_task.project
    @membership = @project.memberships.find_by(user_id: current_user.id)

    if @time_reg.update(time_reg_params)
      redirect_to project_path(@project)
      flash[:notice] = "Time entry has been updated"
    else
      flash[:alert] = "cannot update time entry"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @time_reg = TimeReg.find(params[:id])
    @project = @time_reg.assigned_task.project

    if @time_reg.destroy
      redirect_to project_path(@project)
      flash[:notice] = "Time entry has been deleted"
    else
      flash[:alert] = "cannot delete time entry"
      render :new, status: :unprocessable_entity
    end
  end

  def toggle_active
    @time_reg = TimeReg.find(params[:id])
    @project = @time_reg.assigned_task.project

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
      redirect_to project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end
  def export
    @time_reg = TimeReg.find(params[:time_reg_id])
    @project = @time_reg.assigned_task.project
    @client = Client.find(@project.client_id)
    @time_regs = @project.time_regs
    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      @time_regs.each do |time_reg|
        membership = Membership.find(time_reg.membership.id)

        date = time_reg.date_worked
        client = @client.name
        project = @project.name
        task = Task.find(time_reg.assigned_task.task_id).name
        notes = time_reg.notes
        minutes = time_reg.minutes
        first_name = User.find(time_reg.membership.user_id).first_name
        last_name = User.find(time_reg.membership.user_id).last_name
        email = User.find(time_reg.membership.user_id).email

        csv << [date, client, project, task, notes, minutes, first_name, last_name, email]
      end
    end
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_#{@project.name}.csv"
  end

  private
  def time_reg_params
    params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :membership_id, :date_worked)
  end

  def ensure_membership
    project = TimeReg.find(params[:id]).assigned_task.project

    if !project.memberships.exists?(user_id: current_user)
      flash[:alert] = "Access denied"
      redirect_to root_path
    end
  end


end
